
/*  $Id: loader.js 45479 2020-08-17 15:56:50Z borodine $
 * ===========================================================================
 *
 *                            PUBLIC DOMAIN NOTICE
 *               National Center for Biotechnology Information
 *
 *  This software/database is a "United States Government Work" under the
 *  terms of the United States Copyright Act.  It was written as part of
 *  the author's official duties as a United States Government employee and
 *  thus cannot be copyrighted.  This software/database is freely available
 *  to the public for use. The National Library of Medicine and the U.S.
 *  Government have not placed any restriction on its use or reproduction.
 *
 *  Although all reasonable efforts have been taken to ensure the accuracy
 *  and reliability of the software and data, the NLM and the U.S.
 *  Government do not and cannot warrant the performance or results that
 *  may be obtained by using this software or data. The NLM and the U.S.
 *  Government disclaim all warranties, express or implied, including
 *  warranties of performance, merchantability or fitness for any particular
 *  purpose.
 *
 *  Please cite the author in any work or product based on this material.
 *
 * ===========================================================================
 *
 * File Description: Dynamic scripts loader and synchronizer
 */

timeStamp = new Date().getTime();
(function(){
    var isIE = (window.navigator.userAgent.indexOf('Trident/') >= 0);
    var isGooglebot = (window.navigator.userAgent.indexOf('Googlebot/') >= 0);
    
    var refNode = document.scripts[document.scripts.length - 1];
    if (!refNode || !refNode.src) { // SV-4715 "Standalone SV broken (Brave)"
        window.alert('Not compatible browser!');
        return;
    }
    var srcjs = refNode.src.split('/');
    var viewer = ({sviewer: 'SeqView', treeviewer: 'TreeView', multialign: 'MultiAlignView'})[srcjs.pop().replace('.js', '')];
    if (window[viewer]) return;
    var dl = document.location;
    var externJS = (srcjs[2] != dl.hostname ? '-extern.js' : '.js');
    var dotJS = (srcjs[2].search(/www|qa/) !== 0 || dl.href.indexOf('debug') > 0) ? '-debug.js' : '.js';
    
    var domNCBI = 'ncbi.nlm.nih.gov';
    var re_https_only_site = /(www|dev|test)\.ncbi\.nlm\.nih\.gov/;
    var webNCBI = (dl.hostname.substr(-domNCBI.length) == domNCBI &&
                   !re_https_only_site.test(srcjs[2]) ? dl.protocol : 'https:') + '//'
        + (srcjs[2].indexOf(domNCBI) == -1 || srcjs[2].indexOf('blast.' + domNCBI) >= 0
        ? ('www.' + domNCBI) : srcjs[2]) + '/';

    var ExtJSver = dl.href.substr(dl.href.search(/extjs/), 10).slice(5) || '7.1.0';
    if (!document.querySelector('meta[name=viewport]')) {
        var meta = document.createElement('meta');
        meta.setAttribute('name', 'viewport');
        meta.setAttribute('content', 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no');
        document.getElementsByTagName('head')[0].appendChild(meta);
    }

    var appPath = ''
    for (var i = 3; i < srcjs.length - 1; i++)
        appPath += srcjs[i] + (srcjs[i] ? '/' : '');
    var extPath = webNCBI + 'core/extjs/ext-' + ExtJSver + '/build/';
//    if (dl.href.search(/extjs7./) > 0) extPath = 'https://dev.ncbi.nlm.nih.gov/staff/borodine/ext-' + ExtJSver + '/build/';
    var gbPath = webNCBI + 'projects/genome/browser/2.7/';
    var thirdPartyScripts = {
        Ext: {tag: 'script', attr: {type: 'text/javascript', src: extPath + 'ext-all' + dotJS}},
        jQuery: {tag: 'script', attr: {type: 'text/javascript', src: webNCBI + 'core/jquery/jquery-3.1.0.js'}},
        UUD: {tag: 'script',  attr: {type: 'text/javascript', src: webNCBI +'projects/genome/uud/js/uud' + externJS}},
        TMS: {tag: 'script', attr: {type: 'text/javascript', src: webNCBI + 'projects/genome/trackmgr/0.7/js/tms' + externJS}},
        GB: {tag: 'script', attr: {type: 'text/javascript', src: gbPath + 'js/gbx-hub' + (isIE ? '.js' : dotJS)}},
        ncbi: {tag: 'script', attr: {type: 'text/javascript', src: webNCBI + 'portal/portal3rc.fcgi/rlib/js/InstrumentOmnitureBaseJS/InstrumentNCBIBaseJS/InstrumentPageStarterJS.js'}},
        MSAwasm: {tag: 'script', attr: {type: 'text/javascript', src: webNCBI + appPath + 'js/align_init.js', async: true}},
        ExtCSS: {tag: 'link', attr: {rel: 'stylesheet', type: 'text/css', href: extPath + 'classic/theme-gray/resources/theme-gray-all.css'}},
        GBCSS: {tag: 'link', attr: {rel: 'stylesheet', type: 'text/css', href: gbPath + 'css/gb-hub.css'}}, 
        CSS: {tag: 'link', attr: {rel: 'stylesheet', type: 'text/css', href: webNCBI + appPath + 'css/style.css'}}};

    window[viewer + 'OnReady'] = function(callback, scope) {
        if (typeof window[viewer] === 'undefined')
            setTimeout(function() { window[viewer + 'OnReady'](callback, scope); }, 100);
        else {
            Ext.ariaWarn = Ext.emptyFn;
            Ext.onReady(callback, scope);
        }
    }

    var insertElement = function(resName, callback) {
        var res = thirdPartyScripts[resName];
        var deferCallback = !callback ? function(){} : function() {
            if (dotJS.length > 3) console.log(resName);
            if (!window[resName]) setTimeout(deferCallback, 30);
            else callback();
        }

        if (res.tag == 'link') {
            for (var p in document.styleSheets)
                if (res.attr.href == document.styleSheets[p].href) { res = false; break; }
        } else {
            if (typeof window[resName] !== 'undefined') res = false;
            else {
                for (var p in document.scripts)
                    if (res.attr.src == document.scripts[p].src) { res = false; break;}
            }
        }
        if (!res) {
           deferCallback();
           return;
        }

        var el = document.createElement(res.tag);
        for (var p in res.attr) el[p] = res.attr[p];
        if (typeof callback === 'function') {
            el.onload = el.onreadystatechange = function() {
                if (!this.readyState || this.readyState === "loaded" || this.readyState === "complete") {
                    if (isIE)
                        try {
                            var tmp = document.body.appendChild(document.createElement('div'));
                            tmp.innerText = ' ';
                            document.body.removeChild(tmp);
                        } catch(e){};
                    this.onreadystatechange = this.onload = null;
                    deferCallback();
                }
            }
        }
        refNode.parentNode.insertBefore(el, refNode);
    }
    insertElement('ExtCSS');
    insertElement('CSS');
    if (refNode.getAttribute('extjs') == 'skip') window.Ext = window.Ext || {};

    var counter = 100;

    insertElement('Ext', function finalLoad() {
        if ((typeof Ext === 'undefined' || !Ext.onReady) && counter--) {
            setTimeout(finalLoad, 100);
            return;
        }
        if (Ext.getVersion && Ext.getVersion().major >= 5) {
            Ext.enableAriaButtons = false;
            Ext.scopeCss = true;
            Ext.namespace(viewer);
            Ext.apply(window[viewer], {webNCBI: webNCBI, base_url: webNCBI + appPath, standalone: dl.pathname.indexOf(appPath) == 1});
            window['init' + viewer]();
        } else {
            alert('Current version of the Application works only in ExtJS ver. 6.+ environment!');
            return;
        }
        if (Ext.isIE9) thirdPartyScripts['UUD'].attr.src = thirdPartyScripts['UUD'].attr.src.replace(externJS, '-extern.js');
        if (document.location.hostname.indexOf(domNCBI) == -1) {
            window[viewer].origHostname = document.location.hostname;
            __ncbi_stat_url = 'https://www.ncbi.nlm.nih.gov/stat';
            ncbi_signinUrl = 'https://www.ncbi.nlm.nih.gov/portal/signin.fcgi?cmd=Nop';
            ncbi_pingWithImage = true;    
        } else {
            if (webNCBI.indexOf('https://') != 0) {
               __ncbi_stat_url = 'https://dev.ncbi.nlm.nih.gov/stat';
               ncbi_pingWithImage = true;
            }
        }
        if (viewer == 'MultiAlignView' && !Ext.isIE && !isGooglebot) {
//            DataReady = function() { console.log(arguments, this);}
            insertElement('MSAwasm');
        }
        insertElement('jQuery', function(){
            insertElement('UUD', function() { if (viewer == 'SeqView') {
                insertElement('TMS');
                insertElement('GB');
                insertElement('GBCSS');
            }});
        });
        if (!Ext.removeNodeOrig) {
            Ext.removeNodeOrig = Ext.removeNode;
            Ext.removeNode = function(n) { if (n) Ext.removeNodeOrig(n); }
        }
        if (!(Ext.isEdge|Ext.isSafari|Ext.isFirefox|Ext.isChrome|Ext.isChromeiOS|Ext.isChromeMobile|isGooglebot)) {
            alert('Warning!\nUnsupported internet browser. Some functions may not work.');    
        }

        window[viewer].extPath = extPath;
        window[viewer].extImagesPath = extPath + 'classic/theme-gray/resources/images/';
        window[viewer + 'OnReady'](function(){
            insertElement('ncbi');
            window[viewer].loadApp(refNode);
        });
    });
    
    if (window.NCBIGBUtils && NCBIGBUtils.makeTinyURL) return;

    NCBIGBUtils = window.NCBIGBUtils || {};
    NCBIGBUtils.makeTinyURL = function(url, callback) {
        if (url.indexOf('http') != 0) {
            callback(url);
            return;
        }
        var key = '9add369550da0ca4a4e899358f70be53';
        var url_to_pass = 'https://go.usa.gov/api/shorten.json?login=NLM%20NCBI&apiKey=' + key + '&longUrl=' +
            encodeURIComponent(url);

        jQuery.get(url_to_pass, function(data, status, xhr) {
            var res = 'go.usa.gov url shortener ';
            try {
                res = (data.response.data.entry[0].short_url || '').replace(/http:/, 'https:');
            } catch (e) {
                if (data && data.response && data.response.errorMessage)
                    res += ': ' + data.response.errorMessage;
                else
                    res += 'is not avallable at this moment';
                if (ncbi && ncbi.sg) ncbi.sg.ping({ event: 'url_shortener_failure', err: res });
            }
            callback(res);
        });
    }

})();




/*  $Id: globals.js 45884 2021-01-05 18:39:49Z borodine $
 * ===========================================================================
 *
 *                            PUBLIC DOMAIN NOTICE
 *               National Center for Biotechnology Information
 *
 *  This software/database is a "United States Government Work" under the
 *  terms of the United States Copyright Act.  It was written as part of
 *  the author's official duties as a United States Government employee and
 *  thus cannot be copyrighted.  This software/database is freely available
 *  to the public for use. The National Library of Medicine and the U.S.
 *  Government have not placed any restriction on its use or reproduction.
 *
 *  Although all reasonable efforts have been taken to ensure the accuracy
 *  and reliability of the software and data, the NLM and the U.S.
 *  Government do not and cannot warrant the performance or results that
 *  may be obtained by using this software or data. The NLM and the U.S.
 *  Government disclaim all warranties, express or implied, including
 *  warranties of performance, merchantability or fitness for any particular
 *  purpose.
 *
 *  Please cite the author in any work or product based on this material.
 *
 * ===========================================================================
 *
 * Authors:  Maxim Didenko, Evgeny Borodin, Victor Joukov
 *
 * File Description:
 *
 */

function initMultiAlignView()
{

MultiAlignView.doInitPing = true;

MultiAlignView.loadApp = function (refNode) {
    var items = Ext.query('div[class=MultiAlignViewerApp]');
    for (var i = 0; i < items.length; i++) {
        var id = items[i].id || Ext.id();
        if (!items[i].hasAttribute('data-autoload')) continue;
        if (MultiAlignView.App.findAppByDivId(id)) return;
        items[i].id = id;
        (new MultiAlignView.App(id)).load();
    }
};

MultiAlignView.isFASTA = function(fname) {
    return /\.(a2m|fa|fasta|aln)$/i.test(fname);
}

/* May be move this to the HTML app as an example of state storing/retrieving code
MultiAlignView.Cookies = function(config) {
    this.path = "/";
    this.expires = new Date(new Date().getTime()+(1000*60*60*24*7)); //7 days
    this.domain = ".nih.gov"; // this is essential for proper cookie functioning
    this.secure = false;
    Ext.apply(this, config);

    var readCookies = function() {
        var cookies = {};
        var c = document.cookie + ";";
        var re = /\s?(.*?)=(.*?);/g;
        var matches;
        while((matches = re.exec(c)) != null){
            var name = matches[1];
            // fix incorect cookie name for IE8 (like 'WebCubbyUser; sv-user-data')
            var a = name.split(';');
            name = a[a.length-1].trim();
            var value = matches[2];
            cookies[name] = value;
        }
        return cookies;
    }
    this.state = readCookies();
};

MultiAlignView.Cookies.MaxDate = new Date(new Date('10000/01/01 GMT').getTime()-100);
MultiAlignView.Cookies.UserTracksCookieNameBase = 'ncbi-msav-usertracks-key';
MultiAlignView.Cookies.UserDataCookieNameBase = 'ncbi-msav-userdata-key';
MultiAlignView.Cookies.AppDataCookieNameBase = 'ncbi-msav-data-key';
MultiAlignView.Cookies.UserTracksCookieName = MultiAlignView.Cookies.UserTracksCookieNameBase;
MultiAlignView.Cookies.UserDataCookieName = MultiAlignView.Cookies.UserDataCookieNameBase;
MultiAlignView.Cookies.AppDataCookieName = MultiAlignView.Cookies.AppDataCookieNameBase;

MultiAlignView.Cookies.prototype = {
    get : function(name, defaultValue){
        return typeof this.state[name] == "undefined" ?
            defaultValue : this.state[name];
    },

    set : function(name, value){
        if(typeof value == "undefined" || value === null){
            this.clear(name);
            return;
        }
        this.setCookie(name, value);
        this.state[name] = value;
    },

    clear : function(name){
        delete this.state[name];
        this.clearCookie(name);
    },

    // private
    setCookie : function(name, value){
        document.cookie = name + "=" + value +
           ((this.expires == null) ? "" : ("; expires=" + this.expires.toGMTString())) +
           ((this.path == null) ? "" : ("; path=" + this.path)) +
           ((this.domain == null) ? "" : ("; domain=" + this.domain)) +
           ((this.secure == true) ? "; secure" : "");
    },

    // private
    clearCookie : function(name){
        document.cookie = name + "=del; expires=Thu, 01-Jan-1970 00:00:01 GMT" +
           ((this.path == null) ? "" : ("; path=" + this.path)) +
           ((this.domain == null) ? "" : ("; domain=" + this.domain)) +
           ((this.secure == true) ? "; secure" : "");
    }
};
MultiAlignView.SessionData = new MultiAlignView.Cookies({expires:null, secure:Ext.isSecure});
MultiAlignView.UserTracks = new MultiAlignView.Cookies({expires:MultiAlignView.Cookies.MaxDate, secure:Ext.isSecure});
*/


MultiAlignView.AreaFlags = {
    Link:           (1 << 0), ///< a direct link stored in m_Action
    CheckBox:       (1 << 1), ///< a toggle button/icon
    NoSelection:    (1 << 2), ///< the object can't be selected
    ClientSelection:(1 << 3), ///< the selection can be done on client
    NoHighlight:    (1 << 4), ///< on highlighting on mouse over
    NoTooltip:      (1 << 5), ///< do not request and show tooltip
    TooltipEmbedded:(1 << 6), ///< tooltip embedded
    Track:          (1 << 7), ///< track title bar
    Ruler:          (1 << 8),  ///< ruler bar
    Editable:       (1 << 9),  ///< editable area
    NoPin:          (1 << 10), ///< not pinnable
    IgnoreConflict: (1 << 11), ///< feature can be ignored (isca browser feature editing only)
    Sequence:       (1 << 12), ///< sequence track flag
    Comment:        (1 << 13), ///< render a label/comment on client side
    DrawBackground: (1 << 14), ///< highlight background for this area
    Dirty:          (1 << 16), ///< dirty flag
    NoNavigation:   (1 << 17), ///< no havigation buttons on title bar
    LegendItem:     (1 << 18), ///< legends for graph_overlay tracks
    NoCaching:      (1 << 19)  ///< The tooltip for this feature should not be cached
};

MultiAlignView.getHelpURL = function() {
    return  MultiAlignView.webNCBI + 'tools/msaviewer/';
};

MultiAlignView.showHelpDlg = function(extra_params) {
    window.open(MultiAlignView.getHelpURL() + (extra_params || ''));
};

MultiAlignView.showAboutMessage = function() {
    var msg = '<p>NCBI Multiple Sequence Alignment Viewer - graphical display for the alignments of nucleotide and protein sequences.</p>Version 1.19.2<br><span style="font-size:10px;">Revision: 46168, install date: 2021-01-27 11:05</span><br>';
    msg += '<br>WASM module '+ (MultiAlignView.WASMModuleVersion || 'not initialized') + '<br>';
    msg += '<br>ExtJS version: ' + Ext.getVersion('core').version + '<br>';
    msg += '<br><a href=\"' + MultiAlignView.base_url + 'info.html' + '\" target=\"_blank\" style=\"color:blue\">CGI binaries Info</a>';
    Ext.Msg.show({
        title: 'Multiple Alignment Viewer',
        msg: msg,
        maxWidth: '320',
        minWidth: '300',
        buttons: Ext.Msg.OK
    });
}

MultiAlignView.decode = function(data) { return (typeof data === 'object') ? data : Ext.decode(data); }
//MultiAlignView.getVersion = function() { return 1192; }
MultiAlignView.getVersionString = function() { return '1.19.2'; }
MultiAlignView.AlignDataVersion = '7.0';
//MultiAlignView.WASMModuleVersion = '';

MultiAlignView.area = {
    //links on top
    linkToView: 'top-3',
    feedback: 'top-0',
    //Tool bar actions
    toolbar: {
        back: '2-2-1',      //History
        viewMSA: '2-2-2',      //open full MSA view
        pan: '2-2-4',    //Pan left/right
        slider: '2-2-5',    //Zoom slider
        zoomInOut: '2-2-5-1',    //Zoom In/Out 
        zoomSequence: '2-2-6',    //
        rows: {
            Apply: '2-2-11-Apply'
        },
        columns: {
            Apply: '2-2-12-Apply',
            Default: '2-2-12-Default'
        },
        download: {
            menu: '2-2-8',
            FASTA: '2-2-8-FASTA',
            pdfsvg: '2-2-8-pdfsvg'
        },
        tools: {
            menu: '2-2-7',      //menu Tools
            zoomInOut: '2-2-7-1',    //Zoom In/Out 
            zoomSequence: '2-2-7-3',    //
            uud: '2-2-7-4',      //upload data
            expand: '2-2-7-5',      //expand all
            collapse: '2-2-7-6',      //collapse all
            unsetMaster: '2-2-7-11',
            showConsensus: '2-2-7-consensus',
            showDots: '2-2-7-8',      //show identical bases as dots,
            hideRow: '2-2-12',
            hideSelectedRows: '2-2-13',
            showAllRows: '2-2-14'
        },  
        reload: '2-2-9',     //Reload
        help: {
            menu: '2-2-10',     //Help
            feedback: '2-2-10-0',   //Feedback
            help: '2-2-10-1',   //Help in help menu
            about: '2-2-10-2',   //About
            linkToView: '2-2-10-3',   //Link to view
            legeng: '2-2-10-4'   //legend
        }
    },
    //context menu
    ctxMenu: {
        menu: '3-1',    //Context menu
        zoomInOut: '3-1-1',    //Zoom In/Out
        zoomSequence: '3-1-3',    //Zoom to sequence
        uud: '3-1-4',    //Upload data
        expand: '3-1-5',    //Expand All
        collapse: '3-1-6',    //Collapse All
        viewRowData: '3-1-9', // Sequence View
        setMaster: '3-1-10',
        unsetMaster: '3-1-11',
        showConsensus: '3-1-consensus',
        dwnldConsensus: '3-1-dwnldConsensus',
        showDots: '3-1-8' , //Show identical,
        hideRow: '3-1-12',
        hideSelectedRows: '3-1-13',
        showAllRows: '3-1-14'
    },
    //Coloring menu (Context menu/Toolbar->Coloring)
    coloring: '4-', // + chosen item (text) 
    viewRowData: '5-1', // click on Sequence ID
    expandRow: '5-2',
    selectRow: '5-3',
    sortColumn: 'sortColumn',
    rulerRange: 'rulerRange',
    highlightPos: 'highlightPos',
    //Status bar
    statusbar: {feedback: '10-2',rows:'10-3'},
    //upload  panel
    uploadPanel: '9-5-' //data type or Drag'n'Drop event
}


/* $Id: utils.js 45694 2020-10-26 15:17:12Z borodine $
 * File Description: Univirsal tools and objects
 */
if (!window.NCBIGBUtils || !window.NCBIGBUtils.ClearBrowserSelection) {
var utils = window.NCBIGBUtils = window.NCBIGBUtils || {};
// Decorate long numbers with commas
Number.prototype.commify = function() {
    nStr = this + '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
};

Number.prototype.shorten = function() {
    var value = this.valueOf();
    var negv = ( value < 0 );
    if( negv ) value = -value;
    var Suffixes = [ '', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' ];
    var sfx = '';
    for( var i = 0; i < Suffixes.length; i++ ){
        if( value < 1000 ){
            sfx = Suffixes[i];
            break;
        }
        value /= 1000;
    }
    return ( negv ? '-' : '' ) + Number( value ).toFixed( value < 10 && sfx != '' ? 1 : 0 ) + sfx;
};

// Implementation of Array.findIndex() and Array.find() functions for IE
if (Ext.isIE) {
    if (![].find) {
        Array.prototype.find = function(fn, scope) {
            var ret;
            if (!this.some(function(a, i) {
                    ret = a;
                    return fn.call(scope || this, a, i, this);
                })) return null;
            return ret;
        }
    }
    if (![].findIndex) {
        Array.prototype.findIndex = function(fn, scope) {
            var ret;
            if (!this.some(function(a, i) {
                    ret = i;
                    return fn.call(scope || this, a, i, this);
                })) return -1;
            return ret;
        }
    }
}

/* Cross-Browser Split 1.0.1
(c) Steven Levithan <stevenlevithan.com>; MIT License
An ECMA-compliant, uniform cross-browser split method */

var cbSplit;

// avoid running twice, which would break `cbSplit._nativeSplit`'s reference to the native `split`
if (!cbSplit) {

cbSplit = function (str, separator, limit) {
    // if `separator` is not a regex, use the native `split`
    if (Object.prototype.toString.call(separator) !== "[object RegExp]") {
        return cbSplit._nativeSplit.call(str, separator, limit);
    }

    var output = [],
        lastLastIndex = 0,
        flags = (separator.ignoreCase ? "i" : "") +
                (separator.multiline  ? "m" : "") +
                (separator.sticky     ? "y" : ""),
        separator = RegExp(separator.source, flags + "g"), // make `global` and avoid `lastIndex` issues by working with a copy
        separator2, match, lastIndex, lastLength;

    str = str + ""; // type conversion
    if (!cbSplit._compliantExecNpcg) {
        separator2 = RegExp("^" + separator.source + "$(?!\\s)", flags); // doesn't need /g or /y, but they don't hurt
    }

    /* behavior for `limit`: if it's...
    - `undefined`: no limit.
    - `NaN` or zero: return an empty array.
    - a positive number: use `Math.floor(limit)`.
    - a negative number: no limit.
    - other: type-convert, then use the above rules. */
    if (limit === undefined || +limit < 0) {
        limit = Infinity;
    } else {
        limit = Math.floor(+limit);
        if (!limit) {
            return [];
        }
    }

    while (match = separator.exec(str)) {
        lastIndex = match.index + match[0].length; // `separator.lastIndex` is not reliable cross-browser

        if (lastIndex > lastLastIndex) {
            output.push(str.slice(lastLastIndex, match.index));

            // fix browsers whose `exec` methods don't consistently return `undefined` for nonparticipating capturing groups
            if (!cbSplit._compliantExecNpcg && match.length > 1) {
                match[0].replace(separator2, function () {
                    for (var i = 1; i < arguments.length - 2; i++) {
                        if (arguments[i] === undefined) {
                            match[i] = undefined;
                        }
                    }
                });
            }

            if (match.length > 1 && match.index < str.length) {
                Array.prototype.push.apply(output, match.slice(1));
            }

            lastLength = match[0].length;
            lastLastIndex = lastIndex;

            if (output.length >= limit) {
                break;
            }
        }

        if (separator.lastIndex === match.index) {
            separator.lastIndex++; // avoid an infinite loop
        }
    }

    if (lastLastIndex === str.length) {
        if (lastLength || !separator.test("")) {
            output.push("");
        }
    } else {
        output.push(str.slice(lastLastIndex));
    }

    return output.length > limit ? output.slice(0, limit) : output;
};
cbSplit._compliantExecNpcg = /()??/.exec("")[1] === undefined; // NPCG: nonparticipating capturing group
cbSplit._nativeSplit = String.prototype.split;
} // end `if (!cbSplit)`

// for convenience... interferes with Ext.js interpretation of split, sorry
//String.prototype.split = function (separator, limit) {
//    return cbSplit(this, separator, limit);
//};
// End of Cross-Browser Split

String.prototype.trimToPix = function(length) {
    var tmp = trimmed = utils.sanitize(this);
    if (tmp.visualLength() > length)  {
        trimmed += "...";
        while (trimmed.visualLength() > length)  {
            tmp = tmp.substring(0, tmp.length-1);
            trimmed = tmp + "...";
        }
    }
    return trimmed;
};

String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
};

String.prototype.visualLength = function() {
   var ruler = document.getElementById('string_ruler_unit');
   ruler.innerHTML = this;
   var ret = ruler.offsetWidth;
   ruler.innerHTML = '';
   return ret;
};

utils.ClearBrowserSelection = function() {
    try {
        var sel = window.getSelection ? window.getSelection() : document.selection;
        if (!sel) return;
        if (sel.removeAllRanges) sel.removeAllRanges();
        else 
            if (sel.empty) sel.empty(); 
    } catch(e) {}
};

utils.isNumeric = function(str) { return /^-?[0-9]+(\.[0-9]*)?[km]?$/i.test(str); };

utils.stringToNum = function(pos_str) {
    if (!pos_str) return;
    pos_str = pos_str.replace(/[, ]/g,'');
    if (pos_str.length < 1) return;
    var multiplier = 1;
    var last_char = pos_str.charAt(pos_str.length - 1).toUpperCase();
    if (last_char == 'K' || last_char == 'M') {
        pos_str = pos_str.substr(0, pos_str.length - 1);
        if (last_char == 'K') {
           multiplier = 1000;
        } else {
           multiplier = 1000000;
        }
    }
    var dec_part = 0;
    if (multiplier > 1) {
        var dec_pos = pos_str.indexOf('.');
        if (dec_pos != -1) {
            dec_part = Math.floor(parseFloat(pos_str.substr(dec_pos)) * multiplier);
            pos_str = pos_str.substr(0, dec_pos);
        }
    }
    return multiplier * parseInt(pos_str) + dec_part;
};

// Escape handles symbols innocuous from the point of view of HTML/HTTP
// but used internally in names, which are ususally provided by the user
// and as such are out of control. Encoding schema is according to SV-591
// and SV-1379:
// Prepend \ | , : [ ] with backslash, encode & ; # % as \hex-code, encode
// ' " = and space using standard %hex notation.
// Added a parameter 'symbs' allowing to process only a specific set of symbols
utils.escapeName = function(s, symbs) {
    var res = "";
    var parts = [];
    if (!symbs) parts = cbSplit(s, /([\]\[\\\|\'\"= ,:;&#%])/);
    else parts = cbSplit(s, symbs);
    for (var len = parts.length, i = 0; i < len;) {
        res += parts[i++];
        var sym = parts[i++];
        if (!sym) break;
        if (/[\]\[\\\|,:]/.test(sym))
            res += "\\" + sym;
        else {
            if (/['"= ]/.test(sym))
                res += "%";
            else
                res += "\\"; // ; & # %
            res += sym.charCodeAt(0).toString(16);
        }
    }
    return res;
};

utils.escapeTrackName = function(s, symbs) {
    var res = "";
    if (!symbs) symbs = /([\]\[\\\|,:=&;"#%+])/;
    var parts = cbSplit(s, symbs);
    for (var len = parts.length, i = 0; i < len;) {
        res += parts[i++];
        var sym = parts[i++];
        if (!sym) break;
        res += "\\";
        if (/[=&\\;"#%+]/.test(sym)) {
            res += sym.charCodeAt(0).toString(16);
        } else {
            res += sym;
        }
    }
    return res;
};

utils.unescapeName = function(s) {
    var parts = unescape(s).split("\\");
    var res = parts[0];
    for (var len = parts.length, i = 1; i < len; i++) {
        var part = parts[i];
        if (part.length == 0)
            res += "\\" + parts[++i];
        else if (/[\]\[\\\|,:]/.test(part.charAt(0)))
            res += part;
        else if (/^[0-9a-f]{2}.*/.test(part)) {
            res += String.fromCharCode(parseInt(part.slice(0,2), 16)) + part.slice(2);
        }
    }
    return res;
};


utils.sanitize = function(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;")
            .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
};

// Draw a horizontal ruler with labels on top of it
// Parameters:
//     canvas  - canvas DOM element to draw in
//     base    - canvas base y coordinate, corresponds to ruler horizontal bar
//     start   - canvas x coordinate of ruler start
//     end     - canvas x coordinate of ruler end
//     mdStart - model start, i.e. start label number
//     mdEnd   - model end
utils.drawRuler = function(canvas, base, start, end, mdStart, mdEnd) {

    function logg() {
        //console.log.apply(null, arguments);
    }

    function getLabel(num) {
        return ""+num;
    }

    // scale - how one pixel is projected in model space
    function calcStep(ctx, scale, max_num) {
        function calcTickStep(base_step, scale) {
            var tick_step = base_step;
            [10, 5, 2].forEach(function(n) {
                var step = tick_step / n;
                //logg("n",n,"tick step ", step);
                if (step >= 1 && step / scale > 5) {
                    tick_step = step;
                    return;
                }
            });
            return tick_step;
        }

        var scale_sign = scale < 0 ? -1 : 1;
        scale = Math.abs(scale);

        var logOf10 = Math.log(10);

        var step = Math.pow(10, Math.ceil(Math.log(max_num)/logOf10));

        var maxLabelW = 2*ctx.measureText(""+max_num).width;
        logg("maxLabelW " + maxLabelW);
        var char_w = ctx.measureText("9").width;
        var comma_w = ctx.measureText(",").width;

        var base_step = step;
        if (step > 10.001) {
            var groups_n = 0;
            step = step * 10; // to compensate effect of the first iteration
            var max_label_w = maxLabelW;
            do
            {
                step = step / 10;
                var log = Math.ceil(Math.log(step+1)/logOf10);
                // number of comma-separated groups (111,222,333)
                groups_n = Math.ceil(log / 3);
                if (groups_n)  {
                // abbreviation correction coefficient for 100000 -> 100K etc.
                // should be coordinated with getLabel function
//                    var d_digits =  3 * groups_n - 2;
//                    max_label_w = maxLabelW - d_digits * char_w + (groups_n-1) * comma_w;
                    max_label_w = maxLabelW + (groups_n-1) * comma_w;
                    max_label_sym = scale * max_label_w;
                    logg("step "+step+" groups "+groups_n+" max_label_w " + max_label_w + " max_label_sym " + max_label_sym);
                }
            } while (groups_n  &&  step > max_label_sym*10);
            maxLabelW = max_label_w;
            base_step = step;
            // currently step has 10^X form, lets check if we can choose
            // a smaller step in a form  K * 10^(X-1), where K = 2, 5
            // this adjusment does not affect labels size
            if (step > max_label_sym * 5)    {
                base_step = step / 10;  // 10^(X-1)
                step = step / 5;        // 2 * 10^(X-1)
            }
            else if (step > max_label_sym * 2)   {
                base_step = step / 10;  // 10^(X-1)
                step = step / 2;        // 5 * 10^(X-1)
            }
        }
        var tick_step = calcTickStep(base_step, scale);
        logg("step "+step+" base_step "+base_step+" tick_step "+tick_step);
        logg("step "+step/scale+"px base_step "+base_step/scale+"px");
        return [step, base_step, tick_step, scale_sign];
    }

    var pixLen = end - start + 1;
    var mdLen = mdEnd - mdStart + 1;

    // Here we adjust the pixel region so that the ticks are in the middle
    // of a displayed letter
    var pix_per_letter = Math.abs(pixLen/mdLen);
    if (pix_per_letter > 1) {
        start = Math.round(start + pix_per_letter/2);
        end   = Math.round(end - pix_per_letter/2);
        pixLen = end - start + 1;
    }

    var scale = (mdLen-1) / pixLen;
    logg("scale "+scale);
    var ctx = canvas.getContext("2d");
    ctx.font = "11px Helvetica";
    var res = calcStep(ctx, scale, Math.max(mdStart, mdEnd));
    var mdStep = Math.max(1, res[0]) * res[3],
        mdBaseStep = Math.max(1, res[1]) * res[3],
        mdTickStep = Math.max(1, res[2]) * res[3];
    var labelFreq = mdStep/mdTickStep,
        baseFreq  = mdBaseStep/mdTickStep;
    ctx.textAlign = "center";
    ctx.lineWidth = 1;
    ctx.beginPath();
    var mdStartOffset = Math.ceil(mdStart%mdTickStep);
    if (mdStartOffset) mdStartOffset -= mdTickStep;
    var md_labelOffset = Math.ceil(mdStart%mdStep);
    if (md_labelOffset) md_labelOffset -= mdStep;
    md_labelOffset -= mdStartOffset;
    logg("mdStartOffset", mdStartOffset,
         "md_labelOffset", md_labelOffset);
    var tickStart = Math.ceil(start-mdStartOffset/scale),
        tickEnd = end + 0.5,
        tickStride = mdTickStep/scale,
        tickHeight = 1,
        tickBaseHeight = 2,
        tickLabelHeight = 3,
        tickBase = base + 0.5,
        ticks = pixLen / tickStride + 1,
        labelBase = tickBase - tickLabelHeight-4;

    // draw bar
    ctx.beginPath();
    ctx.moveTo(start+0.5, tickBase);
    ctx.lineTo(end+0.5, tickBase);
    ctx.stroke();
    // draw end ticks
    ctx.moveTo(start+0.5, tickBase - tickLabelHeight);
    ctx.lineTo(start+0.5, tickBase + tickLabelHeight);
    ctx.stroke();
    ctx.moveTo(end+0.5, tickBase - tickLabelHeight);
    ctx.lineTo(end+0.5, tickBase + tickLabelHeight);
    ctx.stroke();

    // draw end labels
    ctx.textAlign = "left";
    var labelText = getLabel(mdStart);
    ctx.fillText(labelText, start, labelBase);
    var px_leftLimit = start + ctx.measureText(labelText).width;
    ctx.textAlign = "right";
    var labelText = getLabel(mdEnd);
    ctx.fillText(labelText, end, labelBase);
    var px_rightLimit = end - ctx.measureText(labelText).width;

    // draw inner ticks and labels
    ctx.textAlign = "center";
    var mdStride = (mdEnd - mdStart) / (ticks-1);
    for (var px_pos = tickStart, tick = 0; px_pos < tickEnd; px_pos += tickStride, ++tick) {
        var x = Math.ceil(px_pos) + 0.5;
        var isLabel = (mdTickStep*tick+md_labelOffset) % mdStep == 0;
        var isBase = (mdTickStep*tick+md_labelOffset) % mdBaseStep == 0;
        var tick_up = isLabel ? tickLabelHeight : 0;
        var tick_down = isLabel ? tickLabelHeight : (isBase ? tickBaseHeight : tickHeight);
        ctx.moveTo(x, tickBase - tick_up);
        ctx.lineTo(x, tickBase + tick_down);
        ctx.stroke();
        if (isLabel) {
            var labelText = getLabel(mdStart-mdStartOffset + Math.round(tick*mdStride));
            var width = ctx.measureText(labelText).width;
            if (x - width/2 > px_leftLimit && x + width/2 < px_rightLimit)
                ctx.fillText(labelText, x, labelBase);
        }
    }
}

utils.clearAria = function(div) {  // clear aria-owns
    Ext.query('[aria-owns]:not([aria-owns=""])', div).forEach(function(el) {
        el.removeAttribute('aria-owns');
    });
    Ext.query('[aria-readonly="false"]', div).forEach(function(el) {
        el.removeAttribute('aria-readonly');
    });
}

/**
*  MD5 (Message-Digest Algorithm)
*  http://www.webtoolkit.info/
**/

utils.MD5 = function (string) {
    function RotateLeft(lValue, iShiftBits) {
        return (lValue<<iShiftBits) | (lValue>>>(32-iShiftBits));
    }
    function AddUnsigned(lX,lY) {
        var lX4,lY4,lX8,lY8,lResult;
        lX8 = (lX & 0x80000000);
        lY8 = (lY & 0x80000000);
        lX4 = (lX & 0x40000000);
        lY4 = (lY & 0x40000000);
        lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);
        if (lX4 & lY4) {
            return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
        }
        if (lX4 | lY4) {
            if (lResult & 0x40000000) {
                return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
            } else {
                return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
            }
        } else {
            return (lResult ^ lX8 ^ lY8);
        }
    }
    function F(x,y,z) { return (x & y) | ((~x) & z); }
    function G(x,y,z) { return (x & z) | (y & (~z)); }
    function H(x,y,z) { return (x ^ y ^ z); }
    function I(x,y,z) { return (y ^ (x | (~z))); }
    function FF(a,b,c,d,x,s,ac) {
        a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
        return AddUnsigned(RotateLeft(a, s), b);
    };
    function GG(a,b,c,d,x,s,ac) {
        a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
        return AddUnsigned(RotateLeft(a, s), b);
    };
    function HH(a,b,c,d,x,s,ac) {
        a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
        return AddUnsigned(RotateLeft(a, s), b);
    };
    function II(a,b,c,d,x,s,ac) {
        a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
        return AddUnsigned(RotateLeft(a, s), b);
    };
    function ConvertToWordArray(string) {
        var lWordCount;
        var lMessageLength = string.length;
        var lNumberOfWords_temp1=lMessageLength + 8;
        var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1 % 64))/64;
        var lNumberOfWords = (lNumberOfWords_temp2+1)*16;
        var lWordArray=Array(lNumberOfWords-1);
        var lBytePosition = 0;
        var lByteCount = 0;
        while ( lByteCount < lMessageLength ) {
            lWordCount = (lByteCount-(lByteCount % 4))/4;
            lBytePosition = (lByteCount % 4)*8;
            lWordArray[lWordCount] = (lWordArray[lWordCount] | (string.charCodeAt(lByteCount)<<lBytePosition));
            lByteCount++;
        }
        lWordCount = (lByteCount-(lByteCount % 4))/4;
        lBytePosition = (lByteCount % 4)*8;
        lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80<<lBytePosition);
        lWordArray[lNumberOfWords-2] = lMessageLength<<3;
        lWordArray[lNumberOfWords-1] = lMessageLength>>>29;
        return lWordArray;
    };
    function WordToHex(lValue) {
        var WordToHexValue="",WordToHexValue_temp="",lByte,lCount;
        for (lCount = 0;lCount<=3;lCount++) {
            lByte = (lValue>>>(lCount*8)) & 255;
            WordToHexValue_temp = "0" + lByte.toString(16);
            WordToHexValue = WordToHexValue + WordToHexValue_temp.substr(WordToHexValue_temp.length-2,2);
        }
        return WordToHexValue;
    };
    function Utf8Encode(string) {
        string = string.replace(/\r\n/g,"\n");
        var utftext = "";
        for (var n = 0; n < string.length; n++) {
            var c = string.charCodeAt(n);
            if (c < 128) {
                utftext += String.fromCharCode(c);
            }
            else if((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }
        }
        return utftext;
    };
    var x=[];
    var k,AA,BB,CC,DD,a,b,c,d;
    var S11=7, S12=12, S13=17, S14=22;
    var S21=5, S22=9 , S23=14, S24=20;
    var S31=4, S32=11, S33=16, S34=23;
    var S41=6, S42=10, S43=15, S44=21;

    string = Utf8Encode(string);
    x = ConvertToWordArray(string);
    a = 0x67452301; b = 0xEFCDAB89; c = 0x98BADCFE; d = 0x10325476;

    for (k=0;k<x.length;k+=16) {
        AA=a; BB=b; CC=c; DD=d;
        a=FF(a,b,c,d,x[k+0], S11,0xD76AA478);
        d=FF(d,a,b,c,x[k+1], S12,0xE8C7B756);
        c=FF(c,d,a,b,x[k+2], S13,0x242070DB);
        b=FF(b,c,d,a,x[k+3], S14,0xC1BDCEEE);
        a=FF(a,b,c,d,x[k+4], S11,0xF57C0FAF);
        d=FF(d,a,b,c,x[k+5], S12,0x4787C62A);
        c=FF(c,d,a,b,x[k+6], S13,0xA8304613);
        b=FF(b,c,d,a,x[k+7], S14,0xFD469501);
        a=FF(a,b,c,d,x[k+8], S11,0x698098D8);
        d=FF(d,a,b,c,x[k+9], S12,0x8B44F7AF);
        c=FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);
        b=FF(b,c,d,a,x[k+11],S14,0x895CD7BE);
        a=FF(a,b,c,d,x[k+12],S11,0x6B901122);
        d=FF(d,a,b,c,x[k+13],S12,0xFD987193);
        c=FF(c,d,a,b,x[k+14],S13,0xA679438E);
        b=FF(b,c,d,a,x[k+15],S14,0x49B40821);
        a=GG(a,b,c,d,x[k+1], S21,0xF61E2562);
        d=GG(d,a,b,c,x[k+6], S22,0xC040B340);
        c=GG(c,d,a,b,x[k+11],S23,0x265E5A51);
        b=GG(b,c,d,a,x[k+0], S24,0xE9B6C7AA);
        a=GG(a,b,c,d,x[k+5], S21,0xD62F105D);
        d=GG(d,a,b,c,x[k+10],S22,0x2441453);
        c=GG(c,d,a,b,x[k+15],S23,0xD8A1E681);
        b=GG(b,c,d,a,x[k+4], S24,0xE7D3FBC8);
        a=GG(a,b,c,d,x[k+9], S21,0x21E1CDE6);
        d=GG(d,a,b,c,x[k+14],S22,0xC33707D6);
        c=GG(c,d,a,b,x[k+3], S23,0xF4D50D87);
        b=GG(b,c,d,a,x[k+8], S24,0x455A14ED);
        a=GG(a,b,c,d,x[k+13],S21,0xA9E3E905);
        d=GG(d,a,b,c,x[k+2], S22,0xFCEFA3F8);
        c=GG(c,d,a,b,x[k+7], S23,0x676F02D9);
        b=GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);
        a=HH(a,b,c,d,x[k+5], S31,0xFFFA3942);
        d=HH(d,a,b,c,x[k+8], S32,0x8771F681);
        c=HH(c,d,a,b,x[k+11],S33,0x6D9D6122);
        b=HH(b,c,d,a,x[k+14],S34,0xFDE5380C);
        a=HH(a,b,c,d,x[k+1], S31,0xA4BEEA44);
        d=HH(d,a,b,c,x[k+4], S32,0x4BDECFA9);
        c=HH(c,d,a,b,x[k+7], S33,0xF6BB4B60);
        b=HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);
        a=HH(a,b,c,d,x[k+13],S31,0x289B7EC6);
        d=HH(d,a,b,c,x[k+0], S32,0xEAA127FA);
        c=HH(c,d,a,b,x[k+3], S33,0xD4EF3085);
        b=HH(b,c,d,a,x[k+6], S34,0x4881D05);
        a=HH(a,b,c,d,x[k+9], S31,0xD9D4D039);
        d=HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);
        c=HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);
        b=HH(b,c,d,a,x[k+2], S34,0xC4AC5665);
        a=II(a,b,c,d,x[k+0], S41,0xF4292244);
        d=II(d,a,b,c,x[k+7], S42,0x432AFF97);
        c=II(c,d,a,b,x[k+14],S43,0xAB9423A7);
        b=II(b,c,d,a,x[k+5], S44,0xFC93A039);
        a=II(a,b,c,d,x[k+12],S41,0x655B59C3);
        d=II(d,a,b,c,x[k+3], S42,0x8F0CCC92);
        c=II(c,d,a,b,x[k+10],S43,0xFFEFF47D);
        b=II(b,c,d,a,x[k+1], S44,0x85845DD1);
        a=II(a,b,c,d,x[k+8], S41,0x6FA87E4F);
        d=II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);
        c=II(c,d,a,b,x[k+6], S43,0xA3014314);
        b=II(b,c,d,a,x[k+13],S44,0x4E0811A1);
        a=II(a,b,c,d,x[k+4], S41,0xF7537E82);
        d=II(d,a,b,c,x[k+11],S42,0xBD3AF235);
        c=II(c,d,a,b,x[k+2], S43,0x2AD7D2BB);
        b=II(b,c,d,a,x[k+9], S44,0xEB86D391);
        a=AddUnsigned(a,AA);
        b=AddUnsigned(b,BB);
        c=AddUnsigned(c,CC);
        d=AddUnsigned(d,DD);
    }
    var temp = WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d);

    return temp.toLowerCase();
}


} //if (window.NCBIGBUtils)
/*  $Id: tooltip.js 45521 2020-08-24 20:18:50Z borodine $
 * File Description: Ext.ToolTip extention
*/
if (!window.NCBIGBObject || !NCBIGBObject.ToolTip) {
Ext.tip.QuickTipManager.init(true);// , {showDelay: 1000, mouseOffset: [-15, 15]});

if (Ext.supports.Touch && Ext.versions.core.version.indexOf('6.0.') == 0) {
    Ext.define('Ext.tip.ToolTip', {
        override: 'Ext.tip.ToolTip',
        setTarget: function(target) {
            var me = this,
                t = Ext.get(target),
                tg;
            if (me.target) {
                tg = Ext.get(me.target);
                if (Ext.supports.Touch) me.mun(tg, 'tap', me.onTargetOver, me);
                me.mun(tg, {
                    mouseover: me.onTargetOver,
                    mouseout: me.onTargetOut,
                    mousemove: me.onMouseMove,
                    scope: me
                });
            }
            me.target = t;
            if (t) {
                if (Ext.supports.Touch)  me.mon(t, { tap: me.onTargetOver, scope: me });
                me.mon(t, {
                    mouseover: me.onTargetOver,
                    mouseout: me.onTargetOut,
                    mousemove: me.onMouseMove,
                    scope: me
                });
            }
            if (me.anchor) {
                me.anchorTarget = me.target;
            }
        }
    });
}

if (Ext.getVersion('core').shortVersion == '650775') {
    Ext.define('Ext.tip.ToolTip', {
        override: 'Ext.tip.ToolTip',
        afterShow: function() {
            this.constrainPosition = false;
            this.callParent(arguments);
        }
    });
}

Ext.define('NCBIGBObject.ToolTip', {
    extend: 'Ext.tip.ToolTip',
    hideDelay: 300,
    showDelay: 1000,
    draggable: true,
    pinned: false,
    autoScroll: false,
    adjustWidth: false,
    pinCallbackFn: Ext.emptyFn,
    header: {
        baseCls: 'x-panel-header',
        padding: 0,
        titlePosition: 99
    },
    listeners: {
        beforehide: function() {
            return !(this.insideTT || this.pinned);
        }
    },
    initComponent: function() {
        if (this.pinnable) delete this.pinnable;
        this.callParent(arguments);
        if (this.isPinnable())
            this.addTool([{type: 'unpin', scope: this, hidden: false, callback: this.toggelPin}]);
     },
/*
     afterRender: function() {
         this.callParent(arguments);
//         this.body.setStyle('position', 'absolute');
    },*/
    isPinnable: function() { return this.pinnable != false; },

    doWidthAdjusting: function() {
        if (!this.adjustWidth || !this.isVisible()) return; 
        var maxW = 490;
            minW = this.getWidth();
        if (maxW < minW || maxW - minW < 50 || minW <= this.minWidth) return;

        var delta = 0,
            curH = this.getHeight(),
            minH = this.setWidth(maxW).getHeight();

        while (minH < curH) {
            delta = maxW - minW;
            delta = delta >> 1;
            curH = this.setWidth(minW + delta).getHeight();
            if (minH < curH++) minW += delta;
            else maxW -= delta;

            if (delta < 3) break;
        }
        this.setWidth(minW + delta);
    },

    onMouseOver: function(e) {
        e.stopEvent();
        this.insideTT = true;
    },

    onMouseOut: function(e) {
        e.stopEvent();
        this.insideTT = e.within(this.el, true, true);
        if (!(this.insideTT || this.pinned)) this.hide();
    },

    onShow: function() {
        this.callParent(arguments);
        this.getEl().on('mouseover', this.onMouseOver, this);
        this.getEl().on('mouseout', this.onMouseOut, this);
        this.doWidthAdjusting();
    },

    toggelPin: function(o, tool) {
        if (!this.pinned) {
            this.pinCallbackFn();
            tool.setType('pin');
            if (!this.isVisible()) this.show();
        } else {
            tool.setType('unpin');
//            NCBIGBObject.ToolTip.superclass.onHide.call(this);
        }
        this.autoHide = !(this.pinned = !this.pinned);
    },
    update: function(html) {
        if (this.adjustWidth) delete this.width; // = 'auto';
        NCBIGBObject.ToolTip.superclass.update.call(this, html);
        this.updateLayout();
        this.doWidthAdjusting();
        if (this.adjustHeight || (!this.isHidden() && this.getWidth() >= 500)) {
            this.setScrollY(25);
            var scrl = this.getScrollY();
            if (scrl && scrl < 25) this.setHeight(this.getHeight() + scrl + 5);
            else this.setScrollY(0);
        }
    }
});
}

/*  $Id: base.js 45556 2020-09-03 15:08:22Z borodine $
 *
 * File Description: base classes 
 *
 */


if (!window.NCBIGBClass) {
Ext.define('NCBIGBClass.View', {
    constructor: function(type, app) {
        this.clear();
        this.m_Type = type;
        this.m_App = app;
        this.m_ReqNum = 0;
        NCBIGBUtils.m_NextViewIdx = NCBIGBUtils.m_NextViewIdx || 0;
        this.m_Idx = NCBIGBUtils.m_NextViewIdx++;
        this.m_View = null;
    },

    isAlignment: function() { return false; },
    isLoading: function() { return this.m_Loading; },
    isGraphic: function() { return false; },
    isPanorama: function() { return false; },
    getBodyDiv: function() { return this.bodyDiv || (this.bodyDiv = Ext.get(this.m_DivId)); },
    getBodyWidth: function() { return this.getBodyDiv().getWidth(); },
    getHeight: function() { return this.m_Height; },
    getMostRightPix: function() { return 0; },
    getSpacerHeight: function() { return 4; },
    getWidth: function() { return this.m_Width; },
    getXY: function() { return this.m_View.getEl().getXY(); },
    moveTo: function(vis_from, vis_len) {},
    ping: function(a) { this.m_App.ping(a); },
    pingClick: function(a, e) { this.m_App.pingClick(a, e); },
    refresh: function() {},
    updateTitle: function() {},
    updateTracks: function() {},
    updateStatusInfo: function() {},

    clear: function() {
        this.m_Loading =  false;
        this.m_ScrollPix = this.m_Width = this.m_Height = 0;
        this.m_Theme = this.m_DivId = this.m_FromCgi = this.m_View = this.m_Color = this.m_Spacer = this.m_Locator = null;
        delete this.m_lastParams;
    },

    createCloseTBar: function() {
        return  {
            id:'close', qtip:'Close View', scope:this,
            handler:function(e, target, panel) {
                this.m_App.viewIsClosing(this);
                if(panel.view) { panel.view.remove(); }
            }
        };
    },

    destroy: function() {
        if (this.m_Locator) {
            this.m_Locator.remove();
        }
        if(this.m_View) {
            if (this.m_Spacer) {
                this.m_View.ownerCt.remove(this.m_Spacer, true);
            }
            this.m_View.ownerCt.remove(this.m_View, true);
        }
        this.clear();
    },

    remove: function() {
        this.m_App.removeView(this);
        this.destroy();
    }
});


/* locator */
NCBIGBClass.Locator = function(view, color, resizable) {
    this.m_View = view; // view
    var panBody = view.m_App.m_Panorama.getBodyDiv();

    var tpl_pan = new Ext.Template('<div class="pan-bar" style="background-color:#{color};position:absolute;top:0px;left:0px;"></div>');
    var tpl = new Ext.Template('<div style="position:absolute;top:17px;left:0px;width:1px;z-index:5;"><div class="locator_rect"></div></div>');
    this.scroller = tpl_pan.insertFirst(panBody, {color:color}, true);
    this.rectangle = tpl.insertFirst(panBody, null, true);
    this.rectangle.setHeight(this.getPanoramaHeight() - 2);

    this.scroller.on({
        'pointerdown'  : this.onPointerDown,
        'contextmenu':  this.onContextMenu,
        scope: this
    });

    if (resizable) {
        (new Ext.Template('<div class="left-resizer"></div>')).insertAfter(this.rectangle.getLastChild());
        this.rectangle.getLastChild().on({
            'pointerdown': this.onPointerDown,
            scope: this
        });
        (new Ext.Template('<div class="right-resizer"></div>')).insertAfter(this.rectangle.getLastChild());
        this.rectangle.getLastChild().on({
            'pointerdown': this.onPointerDown,
            scope: this
        });
        this.setColor({value: color});
    }

};

NCBIGBClass.Locator.prototype = {
    getPanoramaWidth: function() { return this.m_View.m_App.getPanoramaWidth(); },
    getPanoramaHeight: function() { return this.m_View.m_App.getPanoramaHeight(); },
    getRight:  function(local) { return this.rectangle.getRight(local); },
    getWidth:  function(contentWidth) { return this.rectangle.getWidth(contentWidth); },
    setWidth: function(width) { this.rectangle.setWidth(width); },
    setHeight:  function(h) { this.rectangle.setHeight(h - 17); },
    getLeft:  function(local) { return this.rectangle.getLeft(local); },
    setLeft:  function(pos) {
        var panorama_width = this.getPanoramaWidth();
        var bar_pos = pos;
        if(pos + 24 > panorama_width)
            bar_pos = panorama_width - 24;

        this.scroller.setLeft(bar_pos);
        this.rectangle.setLeft(pos);
    },

    setColor:  function(cpicker) {
        this.m_View.m_Color = cpicker.value;
        this.scroller.setStyle('background-color', '#' + cpicker.value);
        this.m_View.m_View.body.setStyle('borderLeft', '#' + cpicker.value + ' 1px solid');
    },


    remove:  function() {
        this.scroller.remove();
        this.rectangle.remove();
    },

    onPointerDown: function(e) {
        if (this.m_ContextMenu) this.m_ContextMenu.destroy();
        if ((e.pointerType == 'mouse' && e.button) || this.m_View.m_App.m_Panorama.m_Loading) return;
        this.m_View.m_App.m_Panorama.m_Locator = this;
        this.downX = Math.round(e.getX());
        this.offsetX = this.getLeft(true) - this.downX;
        this.m_Action = '1-0-R';
        switch (e.getTarget().className) {
            case 'left-resizer':
                this.moveHandler = function(newX) {
                    var new_left = Math.min(this.getRight(true) - 2, Math.max(0, newX));
                    this.setWidth(this.getRight(true) - new_left);
                    this.setLeft(new_left);
                }
                break;
            case 'right-resizer':
                this.offsetX = this.getRight(true) - this.downX;
                this.moveHandler = function(newX) {
                    var new_right = Math.max(this.getLeft(true) + 2,  Math.min(newX, this.getPanoramaWidth()));
                    this.setWidth(new_right - this.getLeft(true));
                }
                break;
            case 'pan-bar':
                if (e.pointerType == 'touch') this.m_deferredContext = Ext.defer(this.onContextMenu, 2000, this);
                this.moveHandler = function(newX) {
                    var new_left = Math.min(this.getPanoramaWidth() - this.getWidth(),  Math.max(0, newX));
                    this.setLeft(new_left);
                    this.m_Action = '1-0-D';
                }
                break;
            default: 
                delete this.offsetX;
                return;
        }
        if (Ext.isIE) e.stopPropagation(); else e.stopEvent();
        this.m_View.m_App.eventHandlers('on', this);
    },

    onPointerUp: function(e) {
        if (this.m_deferredContext) this.m_deferredContext = clearTimeout(this.m_deferredContext);
        e.stopPropagation();
        this.m_View.m_App.eventHandlers('un', this);
        if (typeof this.offsetX != 'undefined') {
            this.m_View.syncToLocator(this.m_Action.slice(-1) == 'D' ? this.m_View.m_VisLenSeq : 0);
            this.m_View.pingClick(this.m_Action);
            delete this.offsetX;
        }
    },

    onPointerMove: function(e) {
        if (typeof this.offsetX == 'undefined') return;
        e.stopPropagation();
        //e.stopEvent();
        NCBIGBUtils.ClearBrowserSelection();
        var majicSensivity = 3;
        if (e.pointerType == 'touch' && this.m_deferredContext) {
            if (Math.abs(this.downX - e.getX()) > majicSensivity) {
                clearTimeout(this.m_deferredContext);
                this.m_deferredContext = 0;
            } else return;
        }
        this.moveHandler(Math.round(e.getX()) + this.offsetX);
    },

    onContextMenu: function(e) {
        var menu = new Ext.menu.Menu();
        delete this.m_Action;
        if (!this.m_deferredContext) {
            e.stopEvent();
        } else {
            this.m_deferredContext = 0;
            this.m_ContextMenu = menu;
        }
        menu.add([{
                text: 'Bring to front', handler:function() {
                    this.rectangle.insertBefore(Ext.get('pan-holder' + this.m_View.m_App.m_Idx));
                    this.scroller.insertAfter(this.rectangle);
                    }, scope: this }, {
                text: 'Sent to back', handler:function() {
                    this.m_View.m_App.m_Panorama.bodyDiv.insertFirst(this.rectangle);
                    this.scroller.insertAfter(this.rectangle);
                    }, scope: this }, {
                text: 'View color change',
                    menu: new Ext.menu.ColorPicker({listeners: { 'select': this.setColor, scope: this }})
                }
            ]);
        menu.showAt(this.scroller.getLeft(false), this.scroller.getBottom(false));
    }
};

Ext.define('NCBIGBClass.Panorama', {
    extend: 'NCBIGBClass.View',
    m_PrevXY: null,
    m_vLine: {setX: Ext.emptyFn, setStyle: Ext.emptyFn},

    constructor: function(app) {
        this.callParent(['panorama', app]);
        this.m_TopOffset = 18; //sm_HolderSize
        this.m_DivId = 'panorama_' + app.m_DivId + app.m_Idx;
        this.m_selectionDivId = 'sel_' + this.m_DivId;
        this.m_View = this.m_App.addView({ 
            html:'<div id="' + this.m_DivId + '" class="panorama_div"><div id="' + this.m_selectionDivId
            + '" class="panoramaSelection" style="z-index:1;">'
            + '</div><div id="pan-holder' + this.m_App.m_Idx + '" class="pan-holder"/>'
        });
        Ext.get(this.m_DivId).on({ scope: this,
            pointerdown: this.onPointerDown,
            pointerup:   this.onPointerUp,
            pointermove: this.onPointerMove,
            contextmenu: this.onContextMenu,
            pointerleave: this.onPointerLeave
        });

        //if  embedded=panorama then do not allow selection
        if (!this.m_App.m_AllViewParams.match("embedded=panorama")) 
            this.m_PanoramaSelection = new NCBIGBClass.PanoramaSelection(this.m_DivId,this.m_selectionDivId, [0,0]);
    },

    onContextMenu: Ext.emptyFunc,

    onPointerLeave:  function(e) {
        this.m_vLine.setStyle('display', 'none');
    },

    isPanorama: function() { return true; },
    
    toPix: function(x) { return x * this.m_Width / this.m_App.getDataLength(); },// sequence 2 screen (panorama)
    toSeq: function(x) { return Math.round(this.m_App.getDataLength() * x / this.m_Width); },
    seq2Pix: function(seq_pos) { return this.toPix(seq_pos); },
    seq2PixScrolled: function(seq_pos) { return this.seq2Pix(seq_pos) + this.m_ScrollPix; },// For panorama m_ScrollPix is always zero, but anyway
    pix2Seq: function(pix_pos) { return this.toSeq(pix_pos); },// screen 2 sequence (gview)
    getMostRightPix: function() { return this.getWidth(); },
    
    onPointerDown: function(e) {
        if (this.m_ContextMenu) this.m_ContextMenu.destroy();
        if (e.pointerType == 'mouse' && e.button) return
        var tID = e.target.id;
        if (this.m_PanoramaSelection && tID.search('scroller') < 0 && tID.search('resizer') < 0){
            this.m_ResizeAction = true;
            this.m_XY = e.getXY();
            if (e.pointerType != 'mouse') {
                this.m_deferredContext = Ext.defer(this.onContextMenu, 2000, this, null);
            } else this.m_deferredContext = 0;
            this.m_XFinal_Selection = this.m_XY[0] + 1;
            this.m_PanoramaSelection.resize(this.m_XY[0], this.m_XFinal_Selection);
            var el =  Ext.get(this.m_selectionDivId);
           if (el) el.applyStyles("display:inline;");
           e.stopEvent();
        }
    },

    onPointerMove: function(e) {
        var magicSensivity = 5; 
        var x = e.getX();
        if (!this.m_ResizeAction || !this.m_PanoramaSelection) {
            this.m_vLine.setStyle('display', 'block');
            this.m_vLine.setX(x);
            return;
        }
        this.m_vLine.setStyle('display', 'none');

        if (this.m_deferredContext) {
            if (Math.abs(x - this.m_XY[0]) <= magicSensivity) return;   
            clearTimeout(this.m_deferredContext);
            this.m_deferredContext = 0;
        }
        this.m_XFinal_Selection = x;
        this.m_PanoramaSelection.resize(this.m_XY[0], x);
        this.m_Selection = true;
        e.stopEvent();
    },

    onPointerUp: function(e) {
        var el =  Ext.get(this.m_selectionDivId);
        if (!el || !el.isVisible() || !this.m_PanoramaSelection) return;
        if (this.m_deferredContext) {   
            clearTimeout(this.m_deferredContext);
            this.m_deferredContext = 0;
        }
        this.m_ResizeAction = false;
        if (Math.abs(this.m_XFinal_Selection - this.m_XY[0]) < 5) {
            el.applyStyles("display:none;");
            return;
        } else {
//            if(this.m_App.m_Views[1]){
                this.m_Locator.setLeft(el.getLeft() - Ext.get(this.m_DivId).getLeft());
                this.m_Locator.setWidth(el.getWidth());
                this.m_Locator.m_View.syncToLocator();
                el.applyStyles("width:0px;display:none;");
                this.pingClick('1-0-1');
//            }
        }
        e.stopPropagation();
    },

    onClick: function(e) {
        var el =  Ext.get(this.m_selectionDivId);
        el.setWidth(0);
        el.hide();
        this.m_ResizeAction = false;
        
    },


    onResize: function(e) {},
    
    createMarkerElem: function(marker) {
        var elem = Ext.get(this.m_DivId);
        var create_params = marker.getCreateParams(true,this.m_Idx);
        var marker_elem = create_params.template.append(elem, create_params.options, true);
        marker_elem.setTop(this.m_TopOffset + 3);
        return marker_elem;
    }
    

});

//////////////////////////////////////////////////////////////////////////
NCBIGBClass.PanoramaSelection = function(panoramaDivId, selectionDivId, range) {
    this.m_selectionDivId = selectionDivId;
    this.m_panoramaDivId = panoramaDivId;
    this.m_Resizing = false;
    this.range = range;
    this.element = Ext.get(this.m_selectionDivId);
};

NCBIGBClass.PanoramaSelection.prototype = {

    pageToViewX: function(x) {
        var div_xy = Ext.get(this.m_panoramaDivId).getXY();
        return x - div_xy[0];
    },

    resize: function(xSelection1, xSelection2) {
        var x1 = this.pageToViewX(xSelection1);
        var x2 = this.pageToViewX(xSelection2);
        var el = this.element;
        el.setLeft(x1 <= x2 ? x1 : x2);
        el.setWidth(Math.abs(x2 - x1));
    }
  
};
}




/*  $Id: msa_base.js 45694 2020-10-26 15:17:12Z borodine $
 *
 * Authors: Evgeny Borodin, Victor Joukov
 *
 * File Description:
 *
 */
/*
var Module = {};
Module['onRuntimeInitialized'] = function() {
    console.log("Module Initialized");
}
*/

Ext.define('MultiAlignView.View',
    {extend: 'NCBIGBClass.View'

});

MultiAlignView.Locator = NCBIGBClass.Locator;

Ext.define('MultiAlignView.Panorama', {
    extend: 'NCBIGBClass.Panorama',
    m_tracks:false,
    onContextMenu: function() {},
    
    updateView: function(callback) {
        var sm_HolderSize = 18;
        var app = this.m_App,
            ruler_height = 26,
            coverage_height = 30,
            the_div = this.getBodyDiv();
        var that = this;
        // ExtJS doesn't process mouseleave reliably, use DOM
        the_div.dom.onmouseleave = function(e) { that.onPointerLeave(that, e); };
        this.m_ControlsHeight = ruler_height + sm_HolderSize + 1;
        this.m_Height = this.m_ControlsHeight;
        the_div.setStyle('height', this.m_Height + 'px' ); 
        this.m_Width = this.getBodyWidth();
        this.m_Ruler = this.m_Ruler || the_div.appendChild(new Ext.Element(document.createElement('canvas')));
        this.m_Ruler.set({style: 'position:absolute;top:' + sm_HolderSize + 'px;left:0px;'});
        this.m_ImageLoaded = 0;
        this.m_ImagesToLoad = 0;

        // remove old coverage and/or tracks
        var old_img = the_div.query('img');
        old_img.forEach(function(img) { the_div.removeChild(img); });  

        var canvas = this.m_Ruler.dom;
        canvas.width  = this.m_Width;
        canvas.height = ruler_height;
        // image for histogram
        the_div.appendChild(new Image()).set({style: 'position: absolute; top:' + this.m_Ruler.getBottom(true) + 'px'});
        
        var params = { view:"msa-coverage", width: this.m_Width, GraphHeight:coverage_height };
        app.addURLParams(params);
        this.m_ImagesToLoad++;
        app.AjaxRequest({ url: app.m_CGIs.Alignment, 
                          data: params, context: this,
                          img_index:0,
                          success: this.processCoverage
                        });

        if (app.m_Anchor) {
            // image for tracks
            this.m_TrackTop = this.m_Ruler.getBottom(true) + coverage_height;
            var from = app.m_Align ? app.m_Align.m_AlignStart : app.m_DataInfo.aln.b;
            var to = app.m_Align ? app.m_Align.m_AlignStop : app.m_DataInfo.aln.e;
            if (from > to) {
                var tmp = from;
                from = to; to = tmp;
            } 
            var len = (to - from) + 1;
            params = {view:"msa", shown:20, rowbeg:0, rowlen:1, width: this.m_Width, from:from, len:len};
            app.addURLParams(params);
            params.expand = app.m_Anchor;
            this.m_ImagesToLoad++;
            app.AjaxRequest({ url: app.m_CGIs.Alignment, 
                              data: params,context: this,
                              success: this.processTrack,
                              img_index:1
                            });
        }
        var drawRuler = function() {
            if (!app.m_Align || !app.m_Align.hasOwnProperty('isReversed')) Ext.defer(drawRuler, 100);
            else {
                var range = app.getAlignRange();
                if (app.m_Align.isReversed && range[0] < range[1]) range.push(range.shift());
                NCBIGBUtils.drawRuler(canvas, ruler_height - 8, 0, canvas.width, range[0] + 1, range[1] + 1);
            }
        }
        drawRuler();
   },


    processData: function(data, img_index) {
        var app = this.m_App,
            the_div = this.bodyDiv,
            from_cgi = this.m_FromCgi = MultiAlignView.decode(data);
        if (from_cgi.job_status) {
            if (from_cgi.job_status == 'failed') {
                console.log('Panorama render error:', from_cgi.error_message);
            } else if(from_cgi.job_status == 'canceled') {
                console.log('Panorama render status: Job canceled');
            } else {
                var url = app.m_CGIs.Alignment + '?job_key=' + from_cgi.job_id
                Ext.Function.defer(app.AjaxRequest, 2000, this, [{url:url, context: this,
                    success: this.processData}]);
            }
            return;
        }
        if (from_cgi.error || from_cgi.success === false) {
            console.log('Panorama render error:', from_cgi.msg || from_cgi.error);
            return;
        }
        
        if (from_cgi.img_url && from_cgi.img_url.charAt(0) == '?') {
            from_cgi.img_url = this.m_App.m_CGIs.NetCache + from_cgi.img_url;
        }
        if (from_cgi.seq_length) this.m_SeqLength = data.seq_length;
                         

        var images = the_div.query('img', false);
        var image = null;
        if (img_index == 1) {
            if (from_cgi.align_info && !(from_cgi.align_info[0].f & this.fNoExpand)) {
                image = the_div.appendChild(new Image()).set({style: 'position:absolute; top:' + this.m_TrackTop + 'px;'});
                images = the_div.query('img', false);
                image = images[img_index];
                this.m_tracks = true;
                this.panorama_img = image;
                delete this.panorama_img_el;
                this.panorama_img_h = -1;
                this.panorama_img_top = -1;
                this.panorama_img_left = -1;
            } else
            {
                if (this.panorama_img)
                    delete this.panorama_img;
                this.m_tracks = false;
                ++this.m_ImageLoaded;
            }
        } else {
            image = images[img_index];
        }
        if (image) 
            image.set({src: from_cgi.img_url,alt:"tile with alignment image", height: from_cgi.img_height});



        var h = 0;
        images.forEach(function(img) {
            if (img.dom.src) ++this.m_ImageLoaded;
            h += img.getHeight();
        }); 
        this.m_Loading = --this.m_ImagesToLoad > 0; // set m_Loading when both images are loaded
        
        this.m_Height = this.m_ControlsHeight + h;
        the_div.setStyle('height', this.m_Height + 'px' );
        this.m_View.updateLayout();
        
        if (!this.m_Loading) {
            this.m_vLine = the_div.appendChild(new Ext.Element(document.createElement('div')));
            this.m_vLine.set({style: 'position:absolute; border:1px solid lightgray; border-right-width:0; top:0;'
                          + 'width:0px; height:' + this.m_Height + 'px; display: none;'});
            if (!this.m_App.m_DialogShown) app.resizeIFrame();

            this.m_App.notifyViewLoaded(this);
        }
    },
    processCoverage: function(data) {
        this.processData(data, 0);

    },
    processTrack: function(data) {
        this.processData(data, 1);

    },
    refresh: function() {
        var app = this.m_App;
        this.updateView(function() { app.forEachView(function(v) {app.updateLocator(v);}); });
    },

    reload: function() {},

    onPointerLeave:  function(e) {
        this.callParent(arguments);
        if (this.m_Selection)
            this.m_Selection = this.m_Selection.remove();
    },

    onPointerMove: function(e) {
        if (this.m_ResizeAction && this.m_PanoramaSelection) {
            this.callParent(arguments);
            // parent m_Selection is boolean, so we erase it
            // it has no sensible use and should be removed from parent
            // onPointerMove method
            this.m_Selection = null;
            return;
        }
        var x = e.getX();
        this.m_vLine.setStyle('display', 'block');
        this.m_vLine.setX(x);

        if (this.m_Selection)
            this.m_Selection = this.m_Selection.remove();

        if (!this.m_tracks) return;

        if (this.panorama_img_h < 0) {
            var pi = document.getElementById(this.panorama_img.id);
            if (pi) {
                this.panorama_img_h = pi.offsetHeight;
                var rect = pi.getBoundingClientRect();
                this.panorama_img_el = pi;
                this.panorama_img_left = rect.left + window.pageXOffset;
                this.panorama_img_top  = rect.top  + window.pageYOffset;
            } else {
                return;
            }
        }
        var img_y = e.getY() - this.panorama_img_top;
        if (img_y >= 0 && img_y < this.panorama_img_h) {
            var img_x = e.getX() - this.panorama_img_left;
            var area = this.m_App.m_Align.makeAreaForPanorama(this.m_App.m_Align.m_AlignInfo[0],
                this.panorama_img_el,"over_selection_light",img_x,img_y);
            this.m_Selection =  new MultiAlignView.AlignSelection(this,area,e);
        }
    }

});
/*  $Id: alignview.js 45929 2021-01-13 18:41:49Z shkeda $
 * ===========================================================================
 *
 *                            PUBLIC DOMAIN NOTICE
 *               National Center for Biotechnology Information
 *
 *  This software/database is a "United States Government Work" under the
 *  terms of the United States Copyright Act.  It was written as part of
 *  the author's official duties as a United States Government employee and
 *  thus cannot be copyrighted.  This software/database is freely available
 *  to the public for use. The National Library of Medicine and the U.S.
 *  Government have not placed any restriction on its use or reproduction.
 *
 *  Although all reasonable efforts have been taken to ensure the accuracy
 *  and reliability of the software and data, the NLM and the U.S.
 *  Government do not and cannot warrant the performance or results that
 *  may be obtained by using this software or data. The NLM and the U.S.
 *  Government disclaim all warranties, express or implied, including
 *  warranties of performance, merchantability or fitness for any particular
 *  purpose.
 *
 *  Please cite the author in any work or product based on this material.
 *
 * ===========================================================================
 *
 * Authors:  Victor Joukov, Evgeny Borodin, Vlad Lebedev, Maxim Didenko
 *
 * File Description:
 *
 */

var _InternalID = function(seq_id,pos)
{
    return seq_id+"@"+pos;
};
//////////////////////////////////////////////////////////////////////
// MultiAlignView.AlignSelection 


function forwardEvent(e, elem) {
    var be = e.browserEvent,
        et = be.type,
        ne = document.createEvent("MouseEvents");
    ne.initMouseEvent(et, true, true, window, be.detail, be.screenX, be.screenY, be.clientX, be.clientY,
        be.ctrlKey, be.altKey, be.shiftKey, be.metaKey, be.button, null);
    elem.dom.dispatchEvent(ne);
}

MultiAlignView.AlignSelection = function(view, area, event) {
    this.id  = area.id;
    this.area = area;
    this.m_View = view;

    // for mouse tracking and delayed tooltp activation
    this.x = null;
    this.y = null;
    var self = this;
    
    var cls = area.cls ? area.cls : "over_selection_light";
    
    var tpl = new Ext.Template('<div class="{cls}" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px;"/>');
try {    
    var element = tpl.append(area.element, {cls:cls, x:area.x, y:area.y, w:area.w, h:area.h}, true);
    element.on({'click': area.onClick || this.m_View.onClick, scope: this.m_View});
    // ExtJS doesn't process mouseleave reliably, use DOM
    // handled by view now
//    var that = this;
//    element.dom.onmouseleave = function(e) { that.removeSelection.call(that); };
} catch(e) {
    console.log(e);
}
    this.element_id = element.id;

    if (area.type == "checkbox") {
        this.qtip = new Ext.ToolTip({
            target: element,
            autoWidth: true, 
            autoHide: true, 
            html: area.descr, 
            dismissDelay: 3000,
            showDelay: 2000,
            bodyStyle: {background: '#f0f0f0'},
            cls: 'MultiAlignViewerApp'
        });
    } else if (area.type == "image" || area.type == "panorama_image") {
        if (view.m_contextMenu && view.m_contextMenu.isVisible()) return;
        this.x = event.pageX, this.y = event.pageY;
        if (!event.ctrlKey && !event.shiftKey && !event.altKey)
            this.deferred = Ext.defer(this.createTooltip, 500, this);
    }



};


MultiAlignView.AlignSelection.prototype = {

    remove: function(all) {
        if (this.deferred) clearTimeout(this.deferred);
        if (this.qtip) this.qtip = this.qtip.destroy();
        if (all) this.m_View.destroyTT();
        var el = Ext.fly(this.element_id);
        if (el) el.remove();
        if (this._tm)
        {
            //unregister in tooltips manager
            this._tm._removeSelection(this._tmid);
        }
        if (this.m_View && this.m_View.m_Selection && this.m_View.m_Selection == this) {
            this.m_View.m_Selection = null;
        }
    },
    removeSelection: function() {
        if (this.m_View && this.m_View.m_Selection && this.m_View.m_Selection == this) {
            this.remove();
        }
    },
    update: function(event) {
        if (this.deferred) clearTimeout(this.deferred);
        if (this.m_View.m_contextMenu && this.m_View.m_contextMenu.isVisible()) return;
        this.x = event.pageX; this.y = event.pageY;
        if (!event.ctrlKey && !event.shiftKey && !event.altKey)
            this.deferred = Ext.defer(this.createTooltip, 500, this);
    },
    createTooltip: function() {
        if (this.qtip) return;
        if (this.m_View.tooltip && !this.m_View.tooltip.pinned) return;
/*        var element = Ext.get(this.element_id);
        var elem_xy = element.getXY();
        var x = this.x - elem_xy[0];
        var y = this.y - elem_xy[1];
        // Fix ajax request with current coords
        var cur_div =  Ext.fly("alignment_id"+this.m_View.m_Idx);
        if (cur_div!= undefined)
        {
            var image_div_xy = cur_div.getXY();
            var image_x = this.x - image_div_xy[0] - this.m_View.m_ScrollPix;
        }*/
        var ajaxCfg = this.area.ajaxCfg;
/*        if (this.area.type != "panorama_image") {
            ajaxCfg.data.x = image_x;
            ajaxCfg.data.y = y + 1;
        }*/
        var tt = ajaxCfg.context = new MultiAlignView.SelectionToolTip({
            dismissDelay: 6000,
            ajaxCfg: ajaxCfg,
            selection: this,
            cls: 'MultiAlignViewerApp'
        });
        tt.update(this.area.descr);
        tt.showAt([this.x + 5, this.y + 5]);

        tt._sel = this;

        if(this.m_View.destroyTT!=undefined)
            this.m_View.destroyTT(tt);
        else if (this.m_View.m_View.destroyTT!=undefined)
            this.m_View.m_View.destroyTT(tt);
    }
};

//////////////////////////////////////////////////////////////////////
// MultiAlignView.SelectionToolTip 
Ext.define('MultiAlignView.SelectionToolTip', {
    extend: 'NCBIGBObject.ToolTip',
    initComponent: function(){
        this.callParent(arguments);
        this.addTool([
            { type: 'up', itemId: 'up', callback: this.collapseHandler, hidden: true, scope: this },
            { type: 'down', itemId: 'down', callback: this.collapseHandler, hidden: true, scope: this }]);
    },

    collapseHandler: function(o, tool, e) {
        this.collapsedTT = tool.type == 'up';
        this.setTTContent();
        this.showAt(this.getXY());
    },

    setTTContent: function() {
        var tt = this.text;
        if (!tt) {
            this.mask('Loading...');
            return;
        }
        if (this.destroyed) return;
        if (this.isMasked() && this.getEl()) this.unmask();

        if (this.title) this.setTitle(this.title);
        if (typeof tt != 'string') return;

        var collapsedToolTips = 'NCBI/MSA/ToolTips/collapse';
        if (typeof this.collapsedTT == 'undefined' && typeof localStorage !== 'undefined')
            this.collapsedTT = !(localStorage[collapsedToolTips] === undefined);
        else
            if (typeof localStorage !== 'undefined') {
                if (!this.collapsedTT) localStorage.removeItem(collapsedToolTips);
                else localStorage.setItem(collapsedToolTips, '');
        }
        var tUp = this.header.down('#up');
        var tDown = this.header.down('#down');
        if (tUp) tUp.hide();
        if (tDown) tDown.hide();
        if (this.collapsedTT) {
            tt = tt.substr(0, tt.indexOf('<hr>') - 20) + '</table>';
            tUp = false;
        } else tDown = false;
// temporary workaround
        var tmp = tt.indexOf('>GeneID:');
        if (tmp > 0) {
            tmp = tt.substr(tmp).split('<td',2)[1].split('<a');
            if (tmp.length == 3) tt = tt.replace('<a' + tmp[1], '');
        }
//workaround end
        this.update(tt);
        var refs = this.el.dom.getElementsByTagName('a');
        for (var i = 0; i < refs.length; ++i) {
            var ref = refs[i];
            if (!ref.href) continue;
            ref.target = "_blank";
        }
        if (tUp) tUp.show();
        if (tDown) tDown.show();
    },

    processResponse: function(data, text, res) {
        if (data) {
            var from_cgi = MultiAlignView.decode(data);
            if (from_cgi.job_status) {
                if (from_cgi.job_status == 'failed' || from_cgi.job_status == 'canceled') 
                    this.text = '<b>Request ' + from_cgi.job_status + '</b><br>' + from_cgi.error_message;
                else {
                    var url = this.m_App.m_CGIs.Alignment + '?job_key=' + from_cgi.job_id
                    Ext.Function.defer(this.m_App.AjaxRequest, 2000, this,[{url:url, context: this,
                        success: function(d, t, r) { this.processResponse(d, t, r);} }]);
                    return;
               }
           }
           if (from_cgi.tooltip) this.text = from_cgi.tooltip;
       }
       if (this.text) {
           this.setTTContent();
           Ext.defer(function(){ if (!this.destroyed) this.hide(); }, 3000, this);
       }
    },

    onRender: function() {
        const collapsedRowHeight = 14;
        var view = this.selection.m_View;
        if (view.m_App.m_AlignTTInfo && !view.isPanorama()) {
            var tt_data = this.ajaxCfg.data;
            var row_info = view.getRowInfo(tt_data.row);
            if (row_info.h < tt_data.y) {
                try {
                    this.onHide();
                    return;
                } catch(e){ console.log('Tooltip coordinates (onhide):', e); }
            }
            try {
                var items = view.m_App.m_AlignTTInfo.fetchTooltipInfo(tt_data.from, tt_data.len, tt_data.x, view.m_AspectPixToSeq, parseInt(tt_data.row));
                var s = '';//'<tr>' + tt_data.row + ':' + pos + '</tr>';
                for (var i = 0; i < items.size(); ++i) {
                    var item = items.get(i);
                    s +="<tr>";
                    if (item.value.length == 0) {
                        s += "<td colspan=2>" + item.key + "</td>";
                    } else {
                        s += "<td valign='top' align='right' nowrap><b>" + item.key + ":</b></td>";
                        s += "<td width='200'>" + item.value + "</td>";
                    }
                    s += "</tr>"
                }
                if (s && tt_data.y <= collapsedRowHeight) this.text = '<table>' + s + '</table>';
            } catch(e) { view.m_App.ping({msaWASM: 'tooltip', error: e});}
            if (items && items.delete) items.delete();
            
            this.processResponse();
        } 
        if (!this.text && this.ajaxCfg) {
            this.ajaxCfg.success = this.processResponse;
            MultiAlignView.App.simpleAjaxRequest(this.ajaxCfg);
        }
        this.callParent(arguments);
    },

    onHide: function() {
        this.selection.m_View.tooltip = null;
        this.callParent(arguments);
        this.destroy();
    },

    afterRender : function() {
        this.callParent(arguments);
        this.setTTContent()
    },
    listeners: {
        beforehide: function()
        {
            //calculate id base on current mouse position.
            if(this._sel!=undefined)
                if(this._sel.m_View!=undefined)
                {
                    var id = _InternalID(this._sel.m_View._seq, this._sel.m_View._seq_pos);
                    if (this._sel._tmid == id)
                    {
                        //console.log("========>this._sel._tmid=",this._sel._tmid," id=",id);
                        return false;
                    }
                    else {
                        //console.log("================>this._sel._tmid=", this._sel._tmid, " id=", id);
                    }
                }
            return !(this.insideTT || this.pinned);
        }
    }

});


var tooltipsManager = tooltipsManager || {};

tooltipsManager = (function() {
    function constructor(app)
    {
        this.m_tooltips = {};
        this.m_App = app;
    }

    return constructor;
}());

tooltipsManager.prototype._InternalID = function(seq_id,pos)
{
    return _InternalID(seq_id,pos);
};

tooltipsManager.prototype._createSelection = function(view, area, event,seq_id,pos)
{
    var id = this._InternalID(seq_id,pos);
    if (this.m_tooltips[id]==undefined)
    {
        //this._removeAllTootips();
        var tt = new MultiAlignView.AlignSelection(view, area,event);
        tt._tm = this;
        tt._tmid = id;
        this.m_tooltips[id]= tt;
    }
    return this.m_tooltips[id];
};


tooltipsManager.prototype._removeSelection = function(id) {
   if (this.m_tooltips[id]!=undefined)
        delete this.m_tooltips[id];
};

tooltipsManager.prototype._removeAllTootips= function() {
    for (var node_id in this.m_tooltips)
    {
        // skip loop if the property is from prototype
        if(!this.m_tooltips.hasOwnProperty(node_id))
            continue;
        if (this.m_tooltips[node_id]!=undefined)
        {
            if(this.m_tooltips[node_id].pinned)
                continue;
            this.m_tooltips[node_id].destroy();
            delete this.m_tooltips[node_id];
        }

    }
};





//////////////////////////////////////////////////////////////////////
// MultiAlignView.Alignment 

MultiAlignView.Alignment = (function() { 
    return Ext.extend(MultiAlignView.View, {
    m_PrevXY: null,
    m_FromSeq: 0,
    m_LenSeq:  0,
    m_ImageFromSeq: 0,
    m_ImageLenSeq: 0,
    m_AlignLen: 0,
    m_ScrollPix: 0,
    m_AspectPixToSeq: 0,
    m_Expand: [],
    m_HiddenSet: new Set(),
    m_History: [],
    // Selection object, follows the mouse
    m_Selection: null,
    m_Selected: {},
    // Additional columns
//    m_DescrCol: null,
    m_ExpandCol: null,
//    m_SeqStartCol: null,
//    m_SeqEndCol: null,
//    m_OrganismCol: null,
    m_StrandHOffset: 2,
    m_StrandVOffset: 3,
    m_CheckboxHOffset: 1,
    m_CheckboxVOffset: 1,
    m_CheckboxSize: 15,
    // Constant flags
    fLocal     : 1,
    fConsensus : 2,
    fNoExpand  : 4,
    
    

//////////////////////////////////////////////////////////////////////////
// constructor:
    
    constructor: function(app) {
        var warn = '<b>Set anchor or show consensus<br>to make data available';
        MultiAlignView.Alignment.superclass.constructor.apply(this, ['alignment', app]);
        this.m_DivId = 'alignment_id' + this.m_Idx;
        this.defaultColumnTable = {
            'd': {name: 'Sequence ID', tooltip: 'Sequence ID', width: 120, border: false, sortable: true, rqv: 'acc'},
            'b': {name: 'Start', tooltip: 'Start', width: 55, border: false, sortable: true},
            'x': {/*name: 'Expand/Collapse',*/ width: 17, border: false },
            'aln': {/*name: 'Alignments',*/ view: this, collapsible: false, header: false, border: false, html: '<div class="alignment_div" id="head_' + this.m_DivId + '"/>'},
            'e': {name: 'End', tooltip: 'End', width: 55, border: false, sortable: true},
            'o': {name: 'Organism', tooltip: 'Organism', width: 150, border: false, sortable: true, rqv: 'org'},
            'cd': {name: 'Date', tooltip: 'Collection Date', width: 65, border: false, sortable: true, hidden: true, rqv: 'collection_date'},
            'cntr': {name: 'Country', tooltip: 'Country', width: 65, border: false, sortable: true, hidden: true, rqv: 'country'},
            'h': {name: 'Host', tooltip: 'Host', width: 65, border: false, sortable: true, hidden: true, rqv: 'host'},
            'is': {name: 'Source', tooltip: 'Isolation Source', width: 65, border: false, sortable: true, hidden: true, rqv: 'source'},
            'gs': {name: 'Gene', tooltip: 'Gene Symbol', width: 50, border: false, sortable: true, hidden: true, rqv: 'gs'},
            'pi': {name: 'Identity', tooltip: '% Identity to anchor/consensus', width: 65, border: false, sortable: true, hidden: true, rqv: 'pi', warn: warn},
            'c': {name: 'Coverage', tooltip: '% Coverage to anchor/consensus', width: 65, border: false, sortable: true, hidden: true, rqv: 'c', warn: warn},
            'as': {name: 'Score', tooltip: 'Alignment Quality Score', width: 65, border: false, sortable: true, hidden: true, rqv: 'as'},
            'mm': {name: 'Mismatches', tooltip: 'Number of mismatches to anchor/consensus', width: 70, border: false, sortable: true, hidden: true, rqv: 'mm', warn: warn}
        };
        this.m_ShowStrand = !app.isProtein();// && (cw.s == undefined || cw.s != 0);
    },

    isAlignment: function() { return true; },

//////////////////////////////////////////////////////////////////////////
// createPanel:

    createPanel: function() {
        var tbar = [],
            tbCfg = this.m_App.m_Toolbar,
            msaArea = MultiAlignView.area.toolbar;
        
        if (tbCfg['history'] == true) {
            tbar.push(
                { iconCls:'back', tooltip: 'Go back',ariaLabel:'Go back', itemId: 'back_button', disabled: true, scope:this,
                    handler:function() { 
                        this.stepHistory();
                        this.pingClick(msaArea.back);
                    }
                }
            );          
        }
        
        if (tbCfg['name'] == true ) {
            tbar.push({ text: '', itemId: 'tbtitle',ariaLabel:"Open in another tab", tooltip: '', width: 200,
                handler: function() { this.openFullView(msaArea.fullView); },  scope:this });
        }
        if (tbCfg['panning'] == true) {
            tbar.push(
                '-',
                {iconCls:'pan-left', tooltip: 'Pan left', scope:this, handler: function() { this.panView(-1); }},
                {iconCls:'pan-right', tooltip: 'Pan right', scope:this, handler: function() { this.panView(1);}},
                '-'
            );
        }

        if (tbCfg["zoom"] == true) {
            tbar.push(
                {text: '&nbsp;&nbsp;-&nbsp;&nbsp;', scale: 'small',tooltip:'Zoom Out',ariaLabel:'Zoom Out', scope:this,
                handler:function() { this.pingClick(msaArea.zoomInOut); this.zoomOut();}}
            );
        
            this.m_TbSlider = new Ext.Slider({
                name: 'zoom', width: 100,  
                minValue: 0, maxValue: 100, value: 0, increment: 5,
                topThumbZIndex: 100,
                tipText: function(thumb){ return String(thumb.value) + '%'; },
                listeners: {
                    scope: this,
                    changecomplete: function(el,val) { 
                        var slider_range = 100;
                        var slider_val = 100 - val;
                                  
                        var vis_range = this.toSeq();
                        var zoom_point = vis_range[0] + vis_range[2] / 2;
                                  
                        var max_bases_to_show = this.m_AlignLen;
                        var rightPix = this.getAlignViewWidth();
                        var min_bases_to_show = rightPix * MultiAlignView.MinBpp;
                        //var min_bases_to_show1 = this.m_App.getPanoramaWidth() / 10;
                       
                        var ee = Math.log(max_bases_to_show / min_bases_to_show);
                         
                        var slider_val = Math.min(slider_range, Math.max(0, slider_val));
                         
                        var len = min_bases_to_show * Math.exp(ee * slider_val / slider_range);
                        var from = zoom_point - len / 2;

                        len = Math.min(this.m_AlignLen, Math.round(len));
                        from = Math.round(Math.max(this.m_AlignStart, from));
                        if (from + len > this.m_AlignStop) {
                            var extra = from + len - this.m_AlignStop;
                            from -= extra;
                        }
                        this.clearPageData();
                        this.loadData(from, len, true);
                        this.pingClick(msaArea.slider);
                    }
                }
            });
            tbar.push(this.m_TbSlider);   

            tbar.push(
                {text: '&nbsp;&nbsp;+&nbsp;&nbsp;', scale: 'small',tooltip:'Zoom In',ariaLabel:'Zoom In', scope:this,
                handler: function() { this.pingClick(msaArea.zoomInOut); this.zoomIn();}},
                {iconCls: 'xsv-zoom_seq', tooltip: 'Zoom To Sequence', ariaLabel: 'Zoom To Sequence', scope:this,
                handler: function() { this.pingClick(msaArea.zoomSequence); this.zoomSeq(); }}
            );
        }

        tbar.push('->');

        if (tbCfg["tools"] == true)
            tbar.push({ text:'Tools', iconCls:'xsv-tools', scope: this, menu: this.createMenu() }, '-');

        if (tbCfg["edit"] == true)
            tbar.push({ text:'Columns', tooltip: 'Columns selection', iconCls:'xsv-config', scope: this.m_App, handler: this.m_App.showColumnsDialog}, '-');
            tbar.push({ text:'Rows', tooltip: 'Rows selection', iconCls:'xsv-config', scope: this.m_App, handler: this.m_App.showRowDialog}, '-');
        if (tbCfg["download"]) {
            tbar.push(
                { text: 'Download', iconCls: 'xsv-download',
                  menu: new Ext.menu.Menu({items: [
                    { text:'FASTA Alignment', scope: this, handler: this.downloadData },
                    { text:'Printer-Friendly PDF/SVG', iconCls:'xsv-printer', disabled: this.m_App.m_NoPDF, scope: this,
                      handler: function() { this.m_App.downloadImgFile(this); }}
                  ]}),
                  scope: this
                }, '-');
        }
            
        var coloring_menu = new Ext.menu.Menu();
        coloring_menu.on('click', function(menu, item) {
            if (item.itemId != 'legend')
                this.m_App.setColoring(item.itemId, true);
            else
                MultiAlignView.showHelpDlg('legend');
            this.pingClick(MultiAlignView.area.coloring + item.itemId);
        }, this);
        coloring_menu.add(this.m_App.getColoringMethods());
        coloring_menu.add([{ xtype: 'menuseparator' },
            { text: 'Disable', itemId: 'disable', iconCls: 'none'},
            { xtype: 'menuseparator' },
            { text: 'Coloring Help', iconCls: 'xsv-question', itemId: 'legend'}
        ]);
        tbar.push( {text: 'Coloring', menu: coloring_menu, iconCls: 'msa-coloring'}, '-');
    
        if (tbCfg["reload"] == true) {
            tbar.push(
                {iconCls:'x-tbar-loading', disabledCls: 'xsv-search-loading', 
                 itemId: 'reload', tooltip: 'Refresh View', scope: this,
                 handler: function() { this.pingClick(msaArea.reload); this.refresh(); }}
            );
        }

        if (tbCfg["help"] == true) {
            tbar.push({
                iconCls: 'xsv-question', 
                tooltip: 'Help', ariaLabel: 'Help',
                layout: {type:'vbox'},
                scope: this, 
                menu: new Ext.menu.Menu({
                    defaultOffsets: [-70,0],
                    items:[{
                        text: 'Help', iconCls: 'xsv-question', scope: this,
                        handler: function() { MultiAlignView.showHelpDlg(); this.pingClick(msaArea.help.help); }
                        }, {
                        text: 'Coloring Legend', scope: this,
                        handler: function() {MultiAlignView.showHelpDlg('legend'); this.pingClick(msaArea.help.legeng);}
                        },{
                        text: 'Link to View', iconCls: 'xsv-link_to_page', scope: this, 
                        handler: function(m, e) {this.m_App.showLinkURLDlg(msaArea.help.linkToView, e);}
                        },{
                        text: 'Feedback', iconCls: 'xsv-feedback', scope: this, 
                        handler: function() {this.m_App.showFeedbackDlg(); this.pingClick(msaArea.help.feedback);}
                        },{
                        text: 'About',  scope: this,
                        handler: function() {MultiAlignView.showAboutMessage(); this.pingClick(msaArea.help.about);}
                    }]
                })
            });
        }
        
        var tools = [];
        if (this.m_App.m_Embedded === false) {
            tools.push(this.createCloseTBar());
        } else {
            tools.push({id:'help',qtip: 'Help', handler: function(){ MultiAlignView.showHelpDlg(); }})
        }
        this.m_View = new Ext.Panel({
            border: false,
            region: 'center',
            height: '100%',
            title: false,
            tbar: tbar
        });
        var panelHead = new Ext.Panel({
            border: false,
            title: false,
            region: 'north',
            layout: 'hbox'});
        var panelRows = new Ext.Panel({
            border: false,
            title: false,
            scrollable: 'y',
//            height: 2000,
            region: 'center',
            layout: 'hbox'
        });
        // Setup columns approximately as in CAlnMultiRenderer::SetupColumns
        this.m_View.add(panelHead, panelRows);
        this.m_View.panelHead = panelHead;
        this.m_View.panelRows = panelRows;
        this.m_View.updateLayout()

        this.m_App.addView(this.m_View);
        this.m_vHighlight = {el: this.m_View.body.appendChild(new Ext.Element(document.createElement('div')))};
        this.m_vHighlight.el.addCls('msa-vHighlight');
        this.m_vHighlight.el.on('pointermove', this.onPointerMove, this);
        this.m_vLine = this.m_View.body.appendChild(new Ext.Element(document.createElement('div')));
        this.m_vLine.addCls('msa-range');
        this.setColumns(this.m_App.m_columns);
        this.statusBar = this.m_View.addDocked({ itemId: 'statusBar',
            xtype: 'toolbar', dock: 'bottom', border: false,
            items: [
                {itemId: 'status', xtype: 'tbtext', text: 'Loading...'},
                {itemId: 'position', xtype: 'tbtext', text: ''},
                '->',
                {itemId: 'feedback', xtype: 'button', text: '', scope: this, iconCls: 'xsv-feedback',
                tooltip: 'Feedback', ariaLabel: 'Feedback',
                handler: function() { this.pingClick(MultiAlignView.area.statusbar.feedback);  this.m_App.showFeedbackDlg(); }},
                {itemId: 'tracks', xtype: 'button', text: '', scope: this, iconCls: 'xsv-config',
                    handler: function (b, e) { this.pingClick(MultiAlignView.area.statusbar.rows);  this.m_App.showRowDialog();}}
            ]
        })[0];
        this.updateStatusBar('feedback', '');

        if (this.m_App.m_Panorama) {
            this.m_Locator = this.m_Locator || new MultiAlignView.Locator(this, this.m_Color, true);
            this.m_App.m_Panorama.m_Locator = this.m_Locator;
        }

        if (this.m_LenSeq > 0)
            this.loadData(this.m_FromSeq, this.m_LenSeq);
        else
            this.loadData();
        var href = Ext.get('new_view_link_al'+this.m_App.m_Idx);
        MultiAlignView.m_pcTBA_standalone
        if (href) { 
            href.on({ 'click' : this.openFullView,  scope:this });
        }
    },

    updateStatusBar: function(prop, text, icon) {
        var st = this.m_View.down('#' + prop);
        if (st) {
            if (typeof text == 'string') st.setText(text);
            if (typeof icon == 'string') st.setStyle('background', icon + (icon ? ' no-repeat' : ''));
            st.setStyle('padding', (st.el.getStyle('background-image') != 'none' ? '0 22px' : '0 3px'));
        }
        return st || {hide: Ext.emptyFn, show: Ext.emptyFn};
    },

    getAlignViewWidth: function() {
        return this.rowsView.body.getWidth() - 2;// + this.fixFF;
    },
/*
    getToolbarTitle: function(){
        var range = this.toSeq();
        var r_range_from = this.m_App.posToLocal(range[0]);
        var r_range_to   = this.m_App.posToLocal(range[1]);
        return r_range_from.commify() + ' - ' + r_range_to.commify() + ' (' + range[2].commify() + (this.m_App.isProtein() ? 'r' : ' bases') + ' shown)';
    },
*/    
    getToolbarTooltip: function() {
        var range = this.toSeq();
        var r_range_from = this.m_App.posToLocal(range[0]);
        var r_range_to   = this.m_App.posToLocal(range[1]);
        
        var tiptitle = '<b>' + this.m_App.m_DataInfo.id;
        tiptitle += ': ' + this.m_App.m_DataInfo.title + '</b><br><br>';
        
        tiptitle += r_range_from.commify() + '&nbsp;-&nbsp;' + r_range_to.commify();
         
        tiptitle += '&nbsp;('+ (range[1] - range[0] + 1).commify() + '&nbsp;';
        tiptitle += (this.m_App.isProtein() ? 'residues' : 'bases');
        tiptitle += '&nbsp;shown';
        
        tiptitle += ")";
        return tiptitle;
    },
    
    addURLParams: function(params) {
        this.m_App.addURLParams(params);
        if (this.m_Expand.length > 0) params.expand = this.m_Expand.join(',');
        if (this.m_HiddenSet.size != 0) params.hidden = Array.from(this.m_HiddenSet).join(',');
    },

    downloadData: function(consensus) {
        var params = { view: 'msa-download', client:'assmviewer' };
        this.addURLParams(params);
        if (consensus === true)
            Ext.apply(params, {visible: this.m_App.m_ConsensusId, anchor: '', consensus: 't'});
        else
            this.pingClick(MultiAlignView.area.toolbar.download.FASTA);
        this.downloadVisualStart();
        this.m_App.AjaxRequest({url: this.m_App.m_CGIs.Alignment,
            context: this, data: params,
            success:this.downloadCheckJobStatus, error:this.downloadFailure});      
    },

    downloadVisualStart: function() {
        this.m_Downloading = true; // start loading
        this.updateStatusBar('status', 'Generating file...', MultiAlignView.ExtIconLoading);
        this.deferred = Ext.defer(this.showFileGenImage, 1000, this);
    },

    showFileGenImage: function() {
        if (this.m_Downloading) {
            var the_div = Ext.get(this.m_DivId);
            the_div.mask('Generating file...');
        }
    },

    downloadVisualDone: function(msg) {
        this.m_Downloading = false;
        Ext.get(this.m_DivId).unmask();
        this.updateStatusBar('status', msg, '');
        if (this.deferred) {
            clearTimeout(this.deferred);
            delete this.deferred;
        }
    },

    downloadFailure: function(data, msg) {
        this.downloadVisualDone(msg);
    },

    downloadCheckJobStatus: function(data, text, res) {
        if (!this.m_Downloading) return;

        var from_cgi = MultiAlignView.decode(data);
        if (from_cgi.job_status) {
            if (from_cgi.job_status == 'failed') {
                this.downloadFailure(null, from_cgi.error_message);
            } else if(from_cgi.job_status == 'canceled') {
                this.downloadFailure(null, 'Job canceled');
            } else {
                var url = this.m_App.m_CGIs.Alignment + '?job_key=' + from_cgi.job_id
                Ext.Function.defer(this.m_App.AjaxRequest, 2000,this,[{url:url, context: this,
                        success: this.downloadCheckJobStatus, error: this.downloadFailure}]);
            }
        } else {
            if (this.deferred) {
                clearTimeout(this.deferred);
                delete this.deferred;
            }

            if (from_cgi.error) {
                this.downloadFailure(null, from_cgi.error);
            } else if (from_cgi.success === false) {
                this.downloadFailure(null, from_cgi.msg);
            } else {
                this.downloadVisualDone('File generated');
                var url = this.m_App.m_CGIs.NetCache + "?fmt=text/plain" +
                    "&key=" + from_cgi.data_key +
                    "&filename=" + from_cgi.file_name;
                // Create form for submitting request to allow browser to handle
                var form = Ext.DomHelper.append(document.body, {
                   tag : 'form',
                   method : 'post',
                   action : url
                });
                document.body.appendChild(form);
                form.submit();
                document.body.removeChild(form);
            }
        }
    },


//////////////////////////////////////////////////////////////////////////
// loadData:
    loadData: function(from, len, history) {
        if (history) this.saveToHistory();
        var width = this.getAlignViewWidth();
        
        var params = { view:'msa', client:'assmviewer', width: width};
        var whole = typeof from == 'undefined' || typeof len == 'undefined'; 
        if (!whole) {
            if (this.m_AlignLen > 0) {
                var new_len  = Math.max(len, Math.floor(width * MultiAlignView.MinBpp));
                if (new_len != len) {
                    from = from + Math.round((len - new_len)/2);
                }
                len = new_len;
                // Check that the ordered window is in alignment boundaries
                // and fix it if needed
                if (len > this.m_AlignLen) len = this.m_AlignLen;
                if (from < this.m_AlignStart) from = this.m_AlignStart;
                if (from + len > this.m_AlignStart + this.m_AlignLen) {
                    from = this.m_AlignStart + this.m_AlignLen - len;
                }
            }
            this.m_FromSeq = from;
            this.m_LenSeq  = len;
        }
        if (whole) {
            // TODO: modify alnmulti.cgi so that it returns whole aligment if no from
            // and length parameters given.
            params.from   = 0;
            params.len    = 4294967295; // MAX_INT32
            this.m_LenSeq = 0;
        } else if (width < 4000 && this.m_AlignLen > 0) {
            // Order up to 4000 pixel image including requested and
            // preserving proportion, calculate the shift so the rendered
            // image would look like requested
            var new_width = 4000;
            var new_len = Math.round(len * new_width / width);
            if (new_len > this.m_AlignLen) {
                new_len = this.m_AlignLen;
                new_width = Math.round(width * new_len / len);
            }
            var new_from = from - Math.round((new_len - len) / 2);
            if (new_from + new_len > this.m_AlignStart + this.m_AlignLen) {
                new_from = this.m_AlignStart + this.m_AlignLen - new_len;
            }
            if (new_from < this.m_AlignStart) {
                new_from = this.m_AlignStart;
            }

            params.from  = new_from;
            params.len   = new_len;
            params.width = new_width;
        } else {
            params.from = from;
            params.len  = len;
        }
/*        if (this.m_AlignLen) {
            var offset = this.isReversed ? (params.from + params.len - from - len) : (params.from - from);
            this.m_ScrollPix = Math.round(offset * params.width / params.len);
        }*/

        this.addURLParams(params);
        this.m_fromCGI = [];

        var master_row = this.m_App.m_ShowConsensus || !!this.m_App.m_Anchor;
        var pages_changed = !this.rowPages; // || ((this.rowPages[0].shown == 4) != master_row);

        if (pages_changed) {
            var rowHeight = 15,
                rowNum = this.m_App.m_DataInfo.aln.total_rows,
                pgSize = Math.min(30, Math.floor(window.innerHeight/rowHeight)),
                top = 0;
            this.rowPages = [{top: 28, shown:28, rowbeg:0, rowlen:1,  // ruler height
                    height: master_row ? 15 : 0 // default consensus/master height
                }];
            var pgs = this.m_App.m_hiddenOptions.indexOf('pgsize');
            if (pgs >= 0) {
                pgSize = parseInt(this.m_App.m_hiddenOptions.substr(pgs + 7));
            }
            // Number.isNaN is ECMA 6 standard not supported by IE 11
            if (isNaN(pgSize) || pgSize <= 0) pgSize = rowNum;
            for (var rowBeg = 0; rowBeg < rowNum; rowBeg += pgSize) {
                var rowLen = (rowBeg + pgSize <= rowNum) ? pgSize : (rowNum - rowBeg);
                this.rowPages.push({top: top, height: rowLen * rowHeight, rowbeg: rowBeg, rowlen: rowLen, shown: 56});
                top += rowLen * rowHeight;
            }
        }
        this.rqParams = params;
        // find and load visible pages
        var vpTop = Math.max(0, window.pageYOffset - this.getBodyDiv().getClientRegion().y),
            vpBottom = window.innerHeight + vpTop;

        // temporary disabling of partial loading 
//        vpTop = 0; vpBottom = top;

        if (this.m_locatorAction) {
            this.m_locatorActionAffectedPages = this.rowPages.length;
            delete this.m_locatorAction;
        } else {
            if (this.m_locatorActionAffectedPages)
                delete this.m_locatorActionAffectedPages;
        }
        this.loadImage(0); 
        for (var i = 1; i < this.rowPages.length; i++) {
            var pg = this.rowPages[i];
            if (pg.top > vpBottom) break;
            if (pg.top + pg.height > vpTop) this.loadImage(i);
        }
    },

    checkDataAvail: function() {
        var top = - Math.floor(this.bodyDiv.dom.getBoundingClientRect().top),
            bottom = top + window.innerHeight;
        for (var i = 0; i < this.rowPages.length; i++) {
            var pg = this.rowPages[i];
            if ((pg.image && pg.image.style.opacity == 1 && pg.align_info ) || pg.requested) continue;
            if (pg.top < bottom && (pg.top + pg.height) > top) this.loadImage(i);
        }        
    },

    loadImage: function(pgNum) {
        if (!this.m_Loading++) {
            this.m_View.down('#reload').disable();
            this.updateStatusBar('status', 'Loading...', MultiAlignView.ExtIconLoading);
            document.getElementById(this.m_App.m_DivId).style.cursor = 'progress';
        //    this.updateStatusBar('tracks').hide();
        }
        var cfg = {url: this.m_App.m_CGIs.Alignment, context: this, data: this.rqParams,
            success: function(d) { this.checkJobStatus(d, pgNum); }, error: this.loadFailure};
        var pg = this.rowPages[pgNum];
        if (pg.image) pg.image.style.opacity = 0.3;

        pg.requested = true;
        Ext.each(['shown', 'rowbeg', 'rowlen'], function(p) { cfg.data[p] = pg[p]; }, this);
        this.m_App.AjaxRequest(cfg);
    },

    checkJobStatus: function(data, pgNum) {
        if (!this.m_Loading) {
            return;
        }
        if (this.updatingPosition) {
            Ext.defer(this.checkJobStatus, 10, this,[data, pgNum]);
            return;
        }
        var from_cgi = MultiAlignView.decode(data);
        if (from_cgi.job_status) {
            if (from_cgi.job_status == 'failed') {
                this.loadFailure(null, from_cgi.error_message);
            } else if(from_cgi.job_status == 'canceled') {
                this.loadFailure(null, 'Job canceled');
            } else {
                var url = this.m_App.m_CGIs.Alignment + '?job_key=' + from_cgi.job_id
                Ext.defer(this.m_App.AjaxRequest, 2000, this, [{url:url, context: this,
                    success: function(d) { this.checkJobStatus(d, pgNum); }, error: this.loadFailure}]);
            }
        } else {
            if (from_cgi.error) {
                this.loadFailure(null, from_cgi.error);
            } else if (from_cgi.success === false) {
                this.loadFailure(null, from_cgi.msg);
            } else {
                var the_div = this.getBodyDiv();
                var pg = this.rowPages[pgNum],
                    image = pg.image;
                delete pg.requested;

                from_cgi.align_info = from_cgi.align_info || [{y: pg.top, h: 0}];
                this.m_fromCGI[pgNum] = from_cgi;
                pg.height = from_cgi.img_height;
                pg.align_info = from_cgi.align_info;
                if (pgNum == 0) {
                    var ai = pg.align_info[0];
                    this.isReversed = ai.id && ai.b > ai.e;
                    this.m_Width = from_cgi.img_width;
                    this.m_ImageFromSeq = from_cgi.from;
                    this.m_ImageLenSeq  = from_cgi.len;
                    
                    if (this.m_LenSeq == 0) {
                        this.m_FromSeq  = from_cgi.from;
                        this.m_LenSeq   = from_cgi.len;
                    }
                    this.m_AlignStart   = from_cgi.aln_start;
                    this.m_AlignStop    = from_cgi.aln_stop;
                    this.m_AlignLen     = from_cgi.aln_stop - from_cgi.aln_start + 1;
                    this.m_AspectPixToSeq = this.m_ImageLenSeq / this.m_Width;
                    this.m_App.m_DataInfo.acc_type = from_cgi.aln_type;
                    this.updateColoringIcon(from_cgi.coloring, 'xsv-search-results');
                    this.m_App.m_Coloring = from_cgi.coloring;
                    
                    if (this.m_AlignLen) {
                        var offset = from_cgi.from - this.m_FromSeq;
                        if (this.isReversed) offset = this.m_FromSeq + this.m_LenSeq - from_cgi.from - from_cgi.len;
                        this.m_ScrollPix = Math.round(offset / this.m_AspectPixToSeq);
                        var sp = this.m_ScrollPix + 'px'; // correct scrollpix for already loaded pages
                        this.rowPages.forEach(function(pg) { if (pg.image && pg.image.style.opacity == 1) pg.image.style.left = sp; });
                    }
                    if (this.m_TbSlider) {
                        var slider_range = 100;
                        var vis_len = this.toSeq()[2];
                        var max_bases_to_show = this.m_AlignLen;
                        var rightPix = this.getAlignViewWidth();
                        var min_bases_to_show = rightPix * MultiAlignView.MinBpp;
                        var ee = Math.log(max_bases_to_show / min_bases_to_show);
                        var slider_val = slider_range * Math.log(vis_len / min_bases_to_show) / ee;
                        this.m_TbSlider.setValue(100 - slider_val);
                    }
                    var head = Ext.get('head_' + this.m_DivId);
                    var canvas_el = head.query('canvas', false)[0] || head.appendChild(document.createElement('canvas'));
                    canvas_el.set({class: 'ruler', style: 'position:absolute; cursor:w-resize; z-index:1;'});
//                    canvas_el.un('click', this.onRulerClick, this);

                    if (this.m_AspectPixToSeq < 0.14) {
                        if (this.inImageRange(this.m_vHighlight.seqPos)) this.highlightPos();
//                        canvas_el.on('click', this.onRulerClick, this);
                    } else this.m_vHighlight.el.setStyle({display:'none'});
                    var canvas = canvas_el.dom;
                    canvas.width  = this.m_Width;
                    canvas.height = pg.top;
                    canvas_el.setX(the_div.getX() + this.m_ScrollPix - 1);
                    var start = this.m_ImageFromSeq + 1,
                        end = start;
                    if (this.isReversed)
                        start += this.m_ImageLenSeq - 1;
                    else
                        end += this.m_ImageLenSeq - 1;
                    NCBIGBUtils.drawRuler(canvas, pg.top - 8, 0, this.m_Width - 1, start, end);
                    var headHeight = pg.top + pg.height + 2;
                    this.m_Height = from_cgi.total_height - pg.height;
                    var alnHeight = this.m_Height + 4;
                    head.setHeight(headHeight);
                    the_div.setHeight(this.m_Height + 4);
                    this.m_ColumnTable.forEach(function(c) {
                        if (!c.order) return;
                        c.elemHead.setHeight(headHeight);
                        c.elem.setHeight(alnHeight);
                    });
                    this.m_View.updateLayout();
                    this.m_View.panelRows.getScrollY(); //tricky workaround on glitch MSA-684 (show all case) 
                } else pg.top = from_cgi.image_start_y;
                var minus2 = -2; // pgNum ? -2 : 0;
                Ext.each(pg.align_info, function() { this.y += pg.top + minus2; });
                if (!image) {
                    var tpl = new Ext.Template('<img class="sv-drag sv-highlight sv-dblclick" style="display:block;top:' + pg.top
                        + 'px;position:absolute;" draggable="false">');
                    pg.image = image = tpl.append(head || the_div);
                }

                image.src = ((from_cgi.img_url.charAt(0) == '?' ? this.m_App.m_CGIs.NetCache : '') + from_cgi.img_url);
                image.style.left = this.m_ScrollPix + 'px';
                image.style.opacity = 1;

                if (pgNum) {
                    pg.image.style.top = (pg.top + 3) + 'px';
                    // recalculating AlignInfo
                    var yy = pg.top + 2;
                    this.m_fromCGI[pgNum].align_info.forEach(function(ai) { ai.y = yy; yy += ai.h });
                    // recalculating rest tops of the pages 
                    for (var i = pgNum + 1; i < this.rowPages.length; i++) {
                        if (this.m_fromCGI[i] === undefined) {
                            this.rowPages[i].top = pg.top + pg.height;
                        }
                        pg = this.rowPages[i];
                        if (pg.image) pg.image.style.top = pg.top + 3 + 'px';
                    }
                }
                this.fillTable(pgNum);

                if (--this.m_Loading) {
                    return; // not everything loaded
                }
                var aInfo = [];
                this.m_fromCGI.forEach(function(data) {
                    aInfo = aInfo.concat(data.align_info || []); }
                );
                this.m_AlignInfo = aInfo;

                this.updateVisuals(true);
                this.loadingDone();
                this.m_App.notifyViewLoaded(this);
            }
        }
    },

    adjustViewPanels: function(callback) {
        var dy = 4,
            off = 0,
            h = this.rowsView.getHeight() + this.statusBar.getHeight() + this.m_View.panelRows.getY() - this.m_View.getY() + dy,
            dh = this.m_View.getY() - this.m_App.m_Panel.getY(),
            panel = this.m_App.getPanel(),
            maxH0 = panel.getMaxHeight(),
            minH = panel.getMinHeight(),
            maxH = Math.max(maxH0 || panel.getHeight(), minH);

        if (this.m_App.m_Panorama && this.m_App.m_Panorama.m_Loading)
            return Ext.defer(this.adjustViewPanels, 10, this, [callback]);

        // h + dh <= maxH
        if(maxH0 != null){
            this.m_View.setHeight(Math.max(Math.min(h, maxH - dh), minH - dh));
            panel.setHeight(Math.min(maxH, h + dh + off));
        }else{
            this.m_View.setHeight(maxH - dh);
        }

        var scrlY = this.m_View.panelRows.getScrollY(); // workaround of an ExtJS bug
        if (scrlY) this.m_View.panelRows.setScrollY(0);
        this.m_View.panelRows.setHeight(this.m_View.down('#statusBar').getY() - this.bodyDiv.getY());
        if (scrlY) this.m_View.panelRows.setScrollY(scrlY);

        this.rowsViewHead.setWidth(this.rowsView.getWidth());
        if (callback) callback();
    },

    loadingDone: function() {
        this.adjustViewPanels();
        this.m_View.down('#reload').enable();
        Ext.get(this.m_DivId).unmask();
        document.getElementById(this.m_App.m_DivId).style.cursor = '';
    },

    loadFailure: function(data, res) {
        this.loadingDone();
        Ext.MessageBox.show({title:'Image loading error', msg:res, buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.INFO});
        var the_div = Ext.get(this.m_DivId);
        the_div.setStyle('background-image', 'none');
        this.updateStatusBar('status', 'Not available');
    },

    fillDelayedPages: function() {
        var IDs = this.m_columnIDs,
            app = this.m_App,
            anchor = app.getMaster();
        if (anchor) {
            if (IDs.indexOf('|pi|') > 0 || IDs.indexOf('|mm|') > 0 || IDs.indexOf('|c|') > 0)
//               (anchor != this.m_App.m_ConsensusId && (IDs.indexOf('|mm|') > 0 || IDs.indexOf('|c|') > 0)))
                    this.rowPages.forEach(function(pg, idx) { if (pg.delayed) this.fillTable(idx); }, this);
        }
        this.rowPages.forEach(function(pg) { delete pg.delayed; });
    },

    fillTable: function(pgNum) {
        var elem = 'elem' + (pgNum ? '' : 'Head'),
            strRuler = document.getElementById('msa_table_ruler'),
            pg = this.rowPages[pgNum],
            tColumn = this.m_ColumnTable;
        if (this.m_App.m_updatingAlignData) {
           pg.delayed = true; 
        } else delete pg.delayed;
        var expand_tpl = new Ext.Template('<div class="x-toolbar-more-icon" data-page={pg} data-msa' + this.m_Idx + ' style="transform:rotate({degree}deg);position:absolute;left:{x}px;top:{y}px;'
            + 'border:1px solid gray;background-position: center;width:{w}px;height:{h}px;filter:alpha(opacity={alpha});opacity:{opacity}"></div>');
        var text_tpl = new Ext.Template('<div data-page={pg}{tt} data-msa' + this.m_Idx + ' style="position:absolute;left:{x}px;top:{y}px;height:{h}px;width:{w}px;'
            + 'border:1px solid gray;{style}">{text}{arrows}</div>');
        // clean up page table
        var attr = 'data-msa' + this.m_Idx,
            rmFunc = 'remove' + (Ext.isIE ? 'Node' : '');
        
        Ext.query('div[data-page="' + pgNum + '"]').forEach(function(el) {if (el.hasAttribute(attr)) el[rmFunc]();}, this);

        var app = this.m_App,
            expand_map = {};
        for (var i = 0; i < this.m_Expand.length; ++i) { expand_map[this.m_Expand[i]] = 1; }
        if (!pgNum) {
            if (!app.getMaster()) {
                tColumn.forEach(function(ct) {
                    if (ct.order && ct.cfg.warn && !ct.ttEl)
                        ct.ttEl = new Ext.ToolTip({target: ct.elem.id, html: ct.cfg.warn, trackMouse: true, showDelay: 300});
                });
            } else {
                tColumn.forEach(function(ct) {
                    if (ct.order && ct.cfg.warn && ct.ttEl) {
                        ct.ttEl.destroy();
                        delete ct.ttEl;
                    }
                });
            }
        }
        for (var i = 0; i < pg.align_info.length; ++i) {
            var rec = pg.align_info[i];
            if (!rec.h) continue;
            var noBorder = '',
                y = rec.y,
                fRec = app.getFullRowInfo(rec.id) || {};
//            if (pgNum) y += 2;
            tColumn.forEach(function(tc) {
                if (!tc.order) return;
                var body = tc[elem].body,
                    tt = '',
                    style = rec.style || '',
                    val = rec[tc.id];
                if (typeof val == 'number') val = (++val).commify();

                switch (tc.id) { 
                    case 'd':
                        tt = ' title="' + val + '\n' + (fRec.title || '') + '"';
                        if (!pgNum) val = '<b>' + val + '</b>';
                        var wID = tc.cfg.width - (this.m_ShowStrand ? 19 : 0);
                        style = 'font-size:12px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;width:' + wID + 'px;'
                        if (!(rec.f & this.fLocal)) {
                            var href = this.getPortalLink(rec);
                            val = '<a onClick="MultiAlignView.App.pingClickByIdx(' + this.m_App.m_Idx + ', \''
                                + MultiAlignView.area.viewRowData + '\');" target="_blank" href=' + href + '>'+ val + '</a>'
                        } else {
                            strRuler.innerHTML = val;
                            if (strRuler.offsetWidth >= wID - 1) {
                                style += 'cursor:pointer;';
                            } else tt = '';
                        }  
                        val = '<table style="margin-top:-2px;"><tr><td><div style="' + style + '">' + val + '</div><td>';
                        style = '';
                        if (this.m_ShowStrand) { // Strand
                            val += '<div style="font-size:9px;font-family:consolas,monospace;'
                                + 'margin-left:-' + (Ext.isFirefox ? 2 : 1) + 'px;"><b>('
                                + (rec.s == '-' ? '&ndash;' : '+') + ')</b></div>';
                        }
                        val += '</tr></table>';
                    break;
                    case 'cntr': case 'cd': case 'is': case 'h': case 'pi': case 'c': case 'mm': case 'gs':
                         val = fRec[tc.cfg.rqv] || ''; //no break;
                    case 'o':
                        style = 'white-space:nowrap;overflow:hidden;text-overflow:ellipsis;padding-left:1px;';
                        strRuler.innerHTML = val;
                        if (strRuler.offsetWidth >= tc.cfg.width - 1) {
                            tt = ' title="' + val + '"';
                            style += 'cursor:pointer;';
                        }
                    break;
                    case 'x':
                        var el = expand_tpl.append(body, {
                            pg: pgNum,
                            degree: rec.id in expand_map ? '270' :  '90',
                            x: this.m_CheckboxHOffset, y: y + this.m_CheckboxVOffset - 1,
                            w: this.m_CheckboxSize, h: this.m_CheckboxSize,
                            alpha: !(rec.f & this.fNoExpand) ? "100" : "40",
                            opacity: !(rec.f & this.fNoExpand) ? "1" : "0.4" });
                        if (!!(rec.f & this.fNoExpand)) el.disabled = true;
                        noBorder = '';
                    // no break;
                    case 'aln': val = false; noBorder = ''; break;
                }
                if (val !== false) {
                    text_tpl.append(body, {text: val, tt: tt, pg: pgNum, x: 0, y: y, h: rec.h + 1, w: tc.cfg.width, style: style + noBorder});
                    noBorder = 'border-left:none;';
                }
            }, this);
        }
    },

    highlightPos: function(pos) {
        if (pos != null) this.m_vHighlight.seqPos = pos;
        var w = 1/this.m_AspectPixToSeq,
            left = Math.round(w * (this.isReversed ?
                   (this.m_ImageFromSeq + this.m_ImageLenSeq - 1 - this.m_vHighlight.seqPos)
                 : (this.m_vHighlight.seqPos - this.m_ImageFromSeq)));
        this.m_vHighlight.el.setStyle({display:'block', left: left + this.bodyDiv.getX() - this.m_App.m_Panel.getX() + this.m_ScrollPix + 'px', width: w + 'px'});
    },

    onPointerDown: function(e) {
        if (this.tooltip) this.tooltip = this.tooltip.destroy();
        if (e.target.getAttribute('class') == 'ruler') {
            this.m_rangeX = e.getX();
            this.m_vLine.shiftX = e.target.parentElement.getBoundingClientRect().left;
            this.m_vLine.setStyle({width: 0, display: 'block', left:this.m_rangeX - this.m_App.m_Panel.getX(), cursor: 'w-resize'});
        }
        this.saveToHistory();
        this.m_InDragAction = true;
        this.m_Moved = false;
        this.m_App.eventHandlers('on', this);
        var area = this.hitTest(e);
        if (!area || area.type == 'checkbox') delete this.m_XY; else this.m_XY = e.getXY();
        e.stopEvent();
    },

    onPointerUp: function(e) {
        if (this.m_InDragAction) this.updateVisuals();
        this.m_InDragAction = false;
        if (this.m_rangeX) {
            delete this.m_rangeX;
            var pos = this.posToSeq((this.isReversed ? this.m_vLine.getRight() : this.m_vLine.getX()) - this.m_vLine.shiftX, this.isReversed);
                len = Math.round(this.m_AspectPixToSeq * this.m_vLine.getWidth()); 
            this.m_vLine.setStyle({width: 0, display: 'none'});
            if (len > 10) {
                this.loadData(pos, len, true);
                this.pingClick(MultiAlignView.area.rulerRange);
            } else
                if (len == 0 && this.m_AspectPixToSeq < 0.14) {
                    this.highlightPos(this.posToSeqFloor(e.getX() - this.bodyDiv.getX()));
                    this.pingClick(MultiAlignView.area.highlightPos);
                }
        }
        Ext.fly(this.m_DivId).setStyle('cursor', 'default');
        this.m_App.eventHandlers('un', this);
        this.m_XY = null;
        e.stopEvent();
    },

    onPointerMove: function(e) {
        e.stopEvent();
        if (this.m_rangeX) {
            var x = e.getX();
            if (x == this.m_rangeX) return;
            this.m_vLine.setStyle({left: Math.min(x, this.m_rangeX) - this.m_App.m_Panel.getX() + 'px', width: Math.abs(x - this.m_rangeX) + 'px', display: 'block'});
            return;
        }
        if (this.m_XY) {
            var xy = e.getXY();
            var delta_x = xy[0] - this.m_XY[0];
            var delta_y = xy[1] - this.m_XY[1];
            if (delta_x != 0 || delta_y > 2) {
                this.m_Moved = true;
                this.scrollView(delta_x);
                if (this.m_Selection) this.m_Selection = this.m_Selection.remove();
                this.m_XY = xy;
                this._seq_pos = null;
                this._seq = null;
                return;
            }
        }
        if (e.target.getAttribute('class') == 'ruler') {
            if (/*e.ctrlKey && */this.m_AspectPixToSeq < 0.14) {
                e.target.style.cursor='pointer';
            } else {
                e.target.style.cursor='w-resize';
            }
            this.m_vLine.setStyle({display:'block', left: e.getX() - this.m_App.m_Panel.getX() + 'px'});
            return;
        }
        var area = this.hitTest(e);
//        this.updateStatusBar('position', area.d + ':' + this._seq_pos + ':' + area.pos);
        if (!area) {
            if (this.m_Selection) this.m_Selection = this.m_Selection.remove();
            this._seq_pos = null;
            this._seq = null;
            return;
        }
        this._seq_pos = this.posToSeqFloor(e.getX() - this.bodyDiv.getX());
        this._seq = area.d;
        if (this.m_Selection) {
            if (this.m_Selection.area.pos == area.pos && this.m_Selection.area.y == area.y) return;
            if (this.m_Selection.area.type == area.type && this.m_Selection.area.id == area.id) {
                this.m_Selection.area = area;
                this.m_Selection.update(e);
                return;
            }
            this.m_Selection.remove();
        }
        this.m_App.m_tooltipsManager._removeAllTootips();
        this.m_Selection = this.m_App.m_tooltipsManager._createSelection(this, area, e, this._seq, this._seq_pos);
    },

    onClick: function(e) {
        var area = this.m_Selection ? this.m_Selection.area : this.hitTest(e);
        if (!area) return;
        var idx = this.m_Expand.findIndex(function(v) { return v == area.id; });
        if (idx < 0) this.m_Expand.push(area.id);
        else this.m_Expand.splice(idx, 1);
        this.pingClick(MultiAlignView.area.expandRow);
        this.reload(true);
    },
    
    onClickSelect: function(e) {
        if (!this.m_Selection || this.m_Moved || this.m_Selection.id == this.m_App.m_Anchor || e.button != 0) return;
        this.stepHistory(true);
        this.pingClick(MultiAlignView.area.selectRow);
        this.m_App.fireEvent('selection_changed', this.m_Selection);
        if (!(e.ctrlKey | e.shiftKey)) {
            this.unselectRows();
            this.m_SelectedLast = this.m_Selection;
        }
        if (e.shiftKey) {
            this.unselectRows();
            if (this.m_SelectedLast == undefined) this.m_SelectedLast = this.m_Selection;
            else if (this.m_SelectedLast != this.m_Selection) {
                var last  = this.getRowIdx(this.m_SelectedLast.id),
                    cur = this.getRowIdx(this.m_Selection.id);
                if (cur > last) { var tmp = last; last = cur; cur = tmp; }
                for (; cur <= last; cur++) this.selectRowByIdx(cur);
                return;
            }
        }
        this.selectRow(this.m_Selection.area.id, true, e.ctrlKey);
    },

    onMouseLeave: function(e) {
        if (this.m_Selection) this.m_Selection = this.m_Selection.remove();
        if (!this.m_rangeX) this.m_vLine.setStyle({display:'none'});
    },

    isLocal: function(id) {
        for (i = 0; i < this.m_AlignInfo.length; i++) {
            if (id == this.m_AlignInfo[i].id) {
                return this.m_AlignInfo[i].f & this.fLocal;
            }
        }
        // should not be reached
        return true; // be on the safe side, assume local id
    },

//////////////////////////////////////////////////////////////////////////
// onContextMenu or Toolbar.tools menu:

    createMenu: function(seq_pos) {
        var app = this.m_App,
            msaArea = seq_pos != undefined ? MultiAlignView.area.ctxMenu : MultiAlignView.area.toolbar.tools,
            menu = new Ext.menu.Menu({closeAction:'close'});
        menu.add('-'); // dummy item for 'beforeshow' to work
        menu.on({
            'beforeshow': function(menu) {
                menu.removeAll();
                menu.add([
                    { iconCls:'xsv-zoom_plus', text:'Zoom In', scope:this,
                      handler:function() {this.pingClick(msaArea.zoomInOut); this.zoomIn(seq_pos);} },
                    { iconCls:'xsv-zoom_minus', text:'Zoom Out', scope:this,
                      handler:function() {this.pingClick(msaArea.zoomInOut); this.zoomOut();} },
                    { xtype: 'menuseparator' },
                    { iconCls:'xsv-zoom_seq', text:'Zoom To Sequence', scope:this,
                      handler:function() {this.pingClick(msaArea.zoomSequence); this.zoomSeq(seq_pos);} },
                    {iconCls:'', text:'Upload data', scope:this,
                      handler: function() {this.pingClick(msaArea.uud); app.showUploadDialog(app.loadDataSuccess, app);}},
                    { xtype: 'menuseparator' },
                    { iconCls:'x-toolbar-more-icon xsv-rotate90', text:'Expand All', scope:this,
                      handler:function() {this.pingClick(msaArea.expand); this.expandAll();} },
                    { iconCls:'x-toolbar-more-icon xsv-rotate270', text:'Collapse All', scope:this,
                      handler:function() {this.pingClick(msaArea.collapse); this.collapseAll();} },
                    { xtype: 'menuseparator' }
                ]);
                var sel = this.m_Selection;
                var add_separator = false;
                if (seq_pos != undefined && sel && !app.isConsensus(sel.id)) {
                    if (!this.isLocal(sel.id)) {
                        menu.add({iconCls: '', text: 'View GenBank ' + sel.area.d, scope: this,
                        handler: function() {
                            this.pingClick(msaArea.viewRowData);
                            window.open(this.getPortalLink(this.getRowInfo(sel.id)));
                        }});
                    }
                    if (app.m_Anchor != sel.id) { 
                        menu.add({ text: 'Set ' + sel.area.d + ' as anchor', rowID: sel.id, scope:this, area: msaArea.setMaster, handler: menuHandler });
                    }
                    add_separator = true;
                } else sel = false;
                if (app.m_Anchor && !app.isConsensus(app.m_Anchor)) {
                    menu.add({text:'Unset anchor row', scope:this, area: msaArea.unsetMaster, handler: menuHandler });
                    add_separator = true;
                }
                if (add_separator) menu.add('-');
                menu.add({ text: 'Show consensus',  xtype: 'menucheckitem', scope: this, checked: app.m_ShowConsensus,
                    disabled: app.m_Anchor && !app.isConsensus(app.m_Anchor), area: msaArea.showConsensus,
                    hidden: app.m_ConsensusId == undefined || app.m_PredefinedConsensus, checkHandler: menuHandler });
                menu.add({ text:'Show identical ' + (app.isProtein() ? 'residues' : 'bases') + ' as dots',
                    xtype: 'menucheckitem', scope: this, area: msaArea.showDots, hidden: !app.m_Anchor,
                    checked: !app.m_ShowIdentical, checkHandler: menuHandler });
                if (seq_pos && app.m_ConsensusId != undefined)
                    menu.add({ text:'Download consensus', iconCls: 'xsv-download', scope: this, area: msaArea.dwnldConsensus, handler:  menuHandler });
                if (sel && app.m_Anchor != sel.id)
                    menu.add({ text: 'Hide  ' + sel.area.d , rowID: sel.id, scope:this, area: msaArea.hideRow, handler: menuHandler });
                if (this.m_Selected && Object.keys(this.m_Selected).length)
                    menu.add({ text: 'Hide selected rows', scope:this, area: msaArea.hideSelectedRows, handler: menuHandler });
                if (this.m_HiddenSet.size != 0)
                    menu.add({ text: 'Show all rows', scope:this, area: msaArea.showAllRows, handler: menuHandler });
            },
            scope: this
        });

        var menuHandler = function(item) {
            this.pingClick(item.area);
            if (item.checkHandler) item.parentMenu.hide();
            switch (item.area) {
                case msaArea.dwnldConsensus: this.downloadData(true); break;
                case msaArea.hideRow: this.hideRows([item.rowID]); break;
                case msaArea.showAllRows: this.showAllRows(); break;
                case msaArea.showDots:
                    this.saveToHistory();
                    this.m_App.setShowIdentical(item.checked, true);
                break;
                case msaArea.hideSelectedRows: this.hideRows(); break;
                case msaArea.showConsensus: this.m_App.m_ShowConsensus = item.checked; // !no break
                default:
                    this.clearPageData();
                    this.clearHistory();
                    this.m_App.setMaster(item.rowID || null, true);
            }            
        }

        return menu;
    },

    onContextMenu: function(e) {
        e.preventDefault();  // this prevents the default contextmenu to open in Firefox (linux)
        e.stopPropagation();
        this.stepHistory(true);
        var page_xy = e.getXY();
        var elem_x = this.rowsView.getEl().getX();
        var xx = page_xy[0] - elem_x;
        var seq_pos = this.posToSeq(xx);

        if (this.m_contextMenu) this.m_contextMenu.destroy();
        this.m_contextMenu = this.createMenu(seq_pos);
        this.m_contextMenu.showAt(page_xy);
        if (this.m_Selection) this.m_Selection = this.m_Selection.remove(true);
    },

//////////////////////////////////////////////////////////////////////////
// toSeq:
//  returns currently viewable region in Seq/Alignment coordinates in format
// [from, to, len]
    toSeq: function() {
        var from = this.isReversed
            ? this.m_ImageFromSeq + this.m_ImageLenSeq - this.m_LenSeq + Math.round(this.m_ScrollPix*this.m_AspectPixToSeq)
            : this.m_ImageFromSeq - Math.round(this.m_ScrollPix*this.m_AspectPixToSeq);
        return [from, from + this.m_LenSeq - 1, this.m_LenSeq];
    },
    
    // posToSeq
    //   x: position in image div coordinates, usually
    //      e.getX() - this.rowsView.getEl().getX()
    //   returns position in alignment or master sequence coordinate, zero based
    posToSeq: function(x, isReversed) {
        var shift = (x - this.m_ScrollPix) * this.m_AspectPixToSeq;
        return Math.round(this.m_ImageFromSeq + (isReversed ? (this.m_ImageLenSeq - shift) : shift));
    },

    posToSeqFloor: function(x) {
        var shift = (x - this.m_ScrollPix) * this.m_AspectPixToSeq;
        return Math.floor(this.m_ImageFromSeq + (this.isReversed ? (this.m_ImageLenSeq - shift) : shift));
    },

    seqToPos: function(x) { return Math.round(this.m_ScrollPix + (x - this.m_ImageFromSeq)/this.m_AspectPixToSeq); },

    inImageRange: function(pos) { return pos >= this.m_ImageFromSeq && pos < this.m_ImageFromSeq + this.m_ImageLenSeq; },

    // API helpers for App
    getRows: function(fSelected) {
        var align_info;
        if (fSelected) {
            var selected = this.m_Selected;
            align_info = this.m_AlignInfo.filter(function(el) {
                return el.id in selected;
            });
        } else {
            align_info = this.m_AlignInfo;
        }
        return align_info.map(function(el) {
            return el.id;
        });
    },
    
    
    getRowInfo: function(rowID) { return this.m_AlignInfo.find(function(row) { return row.id == rowID; }); },
    getRowIdx: function(rowID) { return this.m_AlignInfo.findIndex(function(row) { return row.id == rowID; }); },


    selectRow: function(row_id, doSelect, toggle) {
        var row = this.getRowInfo(row_id)
            selected = row_id in this.m_Selected;
        if (toggle) doSelect = !selected;
        if (doSelect == selected) return;
        if (doSelect) { // select
            area = this.makeAreaForRowRec(row, "selected", "selected_row");
            this.m_Selected[row_id] = new MultiAlignView.AlignSelection(this, area);
        } else {
            this.m_Selected[row_id].remove();
            delete this.m_Selected[row_id];
        }
    },

    selectRowByIdx: function(idx) {
        var area = this.makeAreaForRowRec(this.m_AlignInfo[idx], "selected", "selected_row");
        this.m_Selected[area.id] = new MultiAlignView.AlignSelection(this, area);
    },

    unselectRows: function(rowIDs) {
        var rowIDs = rowIDs || Object.keys(this.m_Selected);
        rowIDs.forEach(function(id) {
            if (!this.m_Selected[id]) return;
            this.m_Selected[id].remove();
            delete this.m_Selected[id];
        }, this);
    },


    updateColoringIcon: function(coloring, iconCls) {
        var menuItem = this.m_View.down('#' + coloring);
        if (menuItem) menuItem.setIconCls(iconCls);
    },

//////////////////////////////////////////////////////////////////////////
// updateVisuals: title, toolbar, locator, selection
    
    updateVisuals: function(update_selection) {
       // update toolbar
        var range = this.toSeq(),
            title = this.m_App.posToLocal(range[0]).commify() + ' - ' + this.m_App.posToLocal(range[1]).commify()
               + ' (' + range[2].commify() + (this.m_App.isProtein() ? 'r' : ' bases') + ' shown)';
        this.m_FromSeq = range[0];

        var tbtitle = this.m_View.down('#tbtitle');
        if (tbtitle) {
            tbtitle.setTooltip(this.getToolbarTooltip());
            tbtitle.setText('<b>' + title + '</b>');
        }
        var master = this.m_App.getMaster();
        if (master) Ext.each(this.m_AlignInfo, function() {
            if (this.id == master) {
                title += ' - anchor ' + this.d;
                return false;
            }
        });

        var icon = this.m_App.m_appWarning ? ('url(' + MultiAlignView.ExtIconLoading.slice(5, -18) + 'shared/warning.gif)') : '';
        var st = this.updateStatusBar('status', this.m_App.m_DataInfo.acc_type.toUpperCase() + ': ' + title, icon);
        if (icon) {
            if (!st.tooltip) st.tooltip = Ext.create('Ext.tip.ToolTip', {target: st.id, title: 'Warning'});
            st.tooltip.setHtml(this.m_App.m_appWarning);
            delete this.m_App.m_appWarning;
        } else if (st.tooltip) st.tooltip = st.tooltip.destroy();

        var tr_tot = this.m_App.m_DataInfo.aln.total_rows;
        this.updateStatusBar('tracks', 'Rows shown: ' + (tr_tot - this.m_HiddenSet.size) + '/' + tr_tot);
        
        if (update_selection) {
            // remove selection element, gather row ids in the process
            var rows = {};
            for (var i in this.m_Selected) {
                var sel = this.m_Selected[i];
                sel.remove();
            }
            // reconstruct selection from row ids
            var elem = this.rowsView.getEl();
            for (var a in this.m_AlignInfo) {
                var rec = this.m_AlignInfo[a];
                if (rec.id in this.m_Selected) {
                    var area = this.makeAreaForRowRec(rec, "selected", "selected_row");
                    var new_sel =  new MultiAlignView.AlignSelection(this, area);
                    this.m_Selected[rec.id] = new_sel;
                }
            }
        }
        this.m_App.updateLocator(this);
        this.m_App.fireEvent('visible_range_changed', this.toSeq());
    },

    makeAreaForRowRec: function(rec, type, cls, x, y) {
        var elem = rec == this.m_AlignInfo[0] ? this.rowsViewHead.getEl() : this.rowsView.getEl();
        var area = { d: rec.d, id: rec.id, x: 0, y: rec.y/* + 2*/, w: elem.getWidth(), h: rec.h + 1,
                    type: type, element: elem, cls: cls, onClick: this.onClickSelect};
        if (typeof x == "number" && typeof y == "number") {
            area.pos = this.posToSeq(x, this.isReversed);
            area.descr = "Alignment position: " + (area.pos + 1);
            // Request is relative to the image, not to the div in which
            // it's scrolled, so we subtract m_ScrollPix
            var params = { view:'msa-tooltip', client:'assmviewer',
                row: rec.id, x: Math.round(x - this.m_ScrollPix), y: Math.round(y - rec.y),
                from: this.m_ImageFromSeq, len: this.m_ImageLenSeq,
                width: this.m_Width};
            this.addURLParams(params);
            area.ajaxCfg = { url: this.m_App.m_CGIs.Alignment, context: this, data: params };
        }
        return area;
    },

    makeAreaForPanorama: function(rec, elem, cls, x, y) {
        var area = { d: rec.d, id: rec.id,
            x: 0, y: 1, w: elem.width, h: elem.height,
            type: 'panorama_image', element: elem, cls: cls,
            pos: this.m_App.m_Panorama.toSeq(x)};
        area.descr = 'Alignment position: ' + (area.pos + 1);
        var params = { view: 'msa-tooltip', client: 'assmviewer', shown: 20,
            expand: rec.id, row: rec.id, x: x, y: y, width: elem.width,
            from: this.m_AlignStart, len: this.m_AlignLen};
        this.addURLParams(params);
        area.ajaxCfg = { url: this.m_App.m_CGIs.Alignment, context: this, data: params };
        return area;
    },

//////////////////////////////////////////////////////////////////////////
// hitTest:
    
    hitTest: function(e) {
        if (!this.m_AlignInfo || e.target.style.opacity == '0.3') return null;
        var rec, area = null,
            yy = e.getY() - window.pageYOffset,
            xx = e.getX() - window.pageXOffset,
            rectBody = this.bodyDiv.dom.getBoundingClientRect(),
            rectHead = this.rowsViewHead.getEl().dom.getBoundingClientRect(),
            outAln = xx < rectBody.left || xx > rectBody.right;
        var i = (yy > rectBody.top) ? 1 : 0,
            length = i ? this.m_AlignInfo.length : 1;

        yy -= i == 0 ? rectHead.top : rectBody.top;
        yy = Math.round(yy);
        xx -= rectBody.left;
        xx = Math.round(xx);
        for (; i < length; i++) {
            if ((rec = this.m_AlignInfo[i]) == null) continue;
            if (yy < rec.y) break;
            if (yy > rec.y + rec.h) continue;
            if (this.m_ExpandCol && outAln) { // Expand/collapse checkbox
                area = { element: this.m_ExpandCol['elem' + (i == 0 ? 'Head' : '')].getEl(),
                    id: rec.id, x: this.m_CheckboxHOffset, y: rec.y + this.m_CheckboxVOffset,
                    w: this.m_CheckboxSize, h: this.m_CheckboxSize,
                    type: 'checkbox', descr: 'Click to expand/collapse'};
                return ((yy < area.y + area.h) && !(rec.f & this.fNoExpand)) ? area : null;
            }
            return this.makeAreaForRowRec(rec, 'image', 'over_selection_light', xx, yy);
        }
        return null;
    },
    
//////////////////////////////////////////////////////////////////////////
// zoomIn:
    
    zoomIn: function(center_seq_pos) {
        if (!center_seq_pos) {
            var r = this.toSeq();
            center_seq_pos = (r[0] + r[1]) / 2;
        }
        var new_len = Math.max(Math.floor(this.m_LenSeq / 2),
                                Math.floor(this.getAlignViewWidth() * MultiAlignView.MinBpp));
        if (new_len == this.m_LenSeq) return;

        var new_from = Math.floor(center_seq_pos - new_len / 2);
        this.clearPageData();
        this.loadData(new_from, new_len, true);
    },

//////////////////////////////////////////////////////////////////////////
// zoomSeq:

    zoomSeq: function(center_seq_pos) {        

        if (!center_seq_pos) {
            var r = this.toSeq();
            center_seq_pos = (r[0] + r[1]) / 2;
        }
        var new_len  = Math.floor(this.getAlignViewWidth() * MultiAlignView.MinBpp); 
        var new_from = Math.floor(center_seq_pos - new_len / 2);

        new_len  = Math.min(new_len, this.m_AlignLen);
        if (new_len == this.m_LenSeq) return;

        new_from = Math.max(this.m_AlignStart, new_from); // not to exceed the sequence range
        this.clearPageData();
        this.loadData(new_from, new_len, true);
    },
    
//////////////////////////////////////////////////////////////////////////
// zoomOut:

    zoomOut: function() {
        var new_len  = this.m_LenSeq * 2;
        var new_from = this.m_FromSeq - Math.floor(this.m_LenSeq / 2);
   
        new_len  = Math.min(new_len, this.m_AlignLen);
        if (new_len == this.m_LenSeq) return;

        new_from = Math.max(this.m_AlignStart, new_from); // not to exceed the sequence range
        this.clearPageData();
        this.loadData(new_from, new_len, true);
    },

    destroyTT: function(newTT) { 
        if (this.tooltip && !this.tooltip.pinned) this.tooltip.destroy();
        this.tooltip = newTT;
    },

    reload: function(cleanAI, whole) {
        this.clearPageData(cleanAI);
        if (!whole) {
            var range = this.toSeq();
            this.loadData(range[0], range[2]);
        } else {
            this.loadData();
        }
    },

    panView: function(sign) {
        if(this.m_TbSlider.getValue()==0)
            return false;

        sign = sign || 1;
        if (this.isReversed) sign = -sign;
        this.pingClick(MultiAlignView.area.toolbar.pan);
        if (this.m_Loading || this.updatingPosition) return false;
        var scrWidth = this.getAlignViewWidth(),
            shift = this.m_LenSeq >> 1,
            newPos = this.m_FromSeq + sign * shift ;
           // newPos = this.m_FromSeq + sign * shift + (sign < 0 ? this.m_LenSeq : 0);
            
        if (newPos < this.m_ImageFromSeq) {
            newPos = Math.max(newPos, this.m_AlignStart);
            shift = Math.min(shift, this.m_FromSeq - this.m_AlignStart);
        }
        if (newPos > this.m_ImageLenSeq + this.m_ImageFromSeq) {
            newPos = Math.min(newPos, this.m_AlignStop);
            shift = Math.min(shift, this.m_AlignStop - this.m_FromSeq - this.m_LenSeq + 1);
        }

        if (this.isReversed) sign = -sign;

        if ((sign>0)&&(newPos + this.m_LenSeq >this.m_AlignStop))
        {
            newPos = this.m_AlignStop - this.m_LenSeq +1;
            shift = Math.min(shift, this.m_AlignStop - this.m_FromSeq - this.m_LenSeq + 1);
        }
        shift = this.m_ScrollPix - sign * Math.round(shift / this.m_AspectPixToSeq);

        if (this.m_ScrollPix == shift) return;
        if (!this.m_InDragAction) this.saveToHistory();

        var delay = 15;
        this.updatingPosition = true;

        var scrlpix = this.m_ScrollPix;
        var children = this.m_View.getEl().query('.sv-drag');
        children.push(this.m_View.getEl().query('canvas')[0]);

        var moveTrx = function(step) {
            step = step || Math.floor((shift - scrlpix)/10);
            if (step == 0) step = shift - scrlpix;
        if (this.m_AspectPixToSeq < 0.14) this.m_vHighlight.el.move('r', step);

            for (var el_index in children) {
                var el = Ext.fly(children[el_index]);
                el.setX(el.getX() + step);
            }
            scrlpix += step;
            if (scrlpix != shift) Ext.defer(moveTrx, delay, this);
            else {
                this.m_ScrollPix = scrlpix;
                delete this.updatingPosition;
                this.updateVisuals();
            }
        };

        moveTrx.call(this);

        // do we need to load next chunk? var preload_margin = this.m_Width/10;
        if (!this.m_Loading  && (newPos < this.m_ImageFromSeq || newPos + this.m_LenSeq > this.m_ImageLenSeq + this.m_ImageFromSeq)) {
            this.loadData(newPos, this.m_LenSeq);
        }
    },

    scrollView: function(delta) {
        if (!delta) return;
        var new_pos = this.m_ScrollPix + delta;

        var screen_width = this.getAlignViewWidth();
        new_pos = Math.min(0, new_pos);
        new_pos = Math.max(new_pos, screen_width-this.m_Width);
        delta = new_pos - this.m_ScrollPix;
        if (!delta) return;
        this.m_ScrollPix += delta;
        if (!this.m_InDragAction) this.saveToHistory();

        // update image position

        var children = this.m_View.getEl().query('.sv-drag');
        children.push(this.m_View.getEl().query('canvas')[0]);
        var left = this.m_ScrollPix + 'px';
        for (var el_index in children) {
            //var el = Ext.fly(children[el_index]);
            //el.setX(el.getX() + delta);
            children[el_index].style.left = left;
        }
        if (this.m_AspectPixToSeq < 0.14) this.m_vHighlight.el.move('r', delta);

        // updateVisuals is too slow for drag action,
        // we call only relevant parts to speed up drag
        // this.updateVisuals();
        this.m_App.updateLocator(this);
        this.m_App.fireEvent('visible_range_changed', this.toSeq());

        // do we need to load next chunk?
        var preload_margin = this.m_Width/10;
        if (!this.m_Loading
            && ((delta > 0 && this.m_ImageFromSeq > this.m_AlignStart && new_pos > -preload_margin)
                || (delta < 0 && this.m_ImageFromSeq + this.m_ImageLenSeq <= this.m_AlignStop && new_pos < screen_width - this.m_Width + preload_margin)))
        {
            this.reload();
        }
    },
    
    expandAll: function() {
        this.m_Expand[this.m_App.m_DataInfo.aln.total_rows];
        for (var i = this.m_App.m_DataInfo.aln.total_rows; i--;) this.m_Expand[i] = i;
        this.reload(true);
    },

    collapseAll: function() {
        this.m_Expand = [];
        this.reload(true);
    },

    setHidden: function(rowIDs) {
        this.m_HiddenSet = new Set(rowIDs);
        this.m_HiddenSet.delete(this.m_App.m_Anchor);
        this.reload(true);
    },

    hideRows: function(rowIDs) {
        delete this.m_SelectedLast;
        rowIDs = rowIDs || Object.keys(this.m_Selected);
        rowIDs.forEach(function (id) { this.m_HiddenSet.add(id); }, this);
        if (rowIDs.length > 20) this.m_View.panelRows.setScrollY(0);
        this.unselectRows(rowIDs);
        this.reload(true);
    },

    refresh: function(options) { if (this.m_VisLenSeq != 0) this.reload(options); },

    showAllRows: function() {
        if (this.m_HiddenSet.size != 0) {
            delete this.m_SelectedLast;
            this.m_HiddenSet.clear();
            this.reload(true);
        }
    },

    initColumns: function() {
        var aln,
            pHead = this.m_View.panelHead,
            pRows = this.m_View.panelRows,
            that = this;
        function leave(e) { that.onMouseLeave(e); }
        var eventHandlers = {
            pointerdown: this.onPointerDown,
            pointermove: this.onPointerMove,
            contextmenu: this.onContextMenu,
            scope: this
        };
        pHead.removeAll();
        pHead.remove()
        pRows.removeAll();
        delete this.bodyDiv;
        delete this.rowPages;
        delete this.m_ExpandCol;

        var app = this.m_App;
        function clearIcons()
        {
            function clearIcon(item) {
                item.setIconCls(null);
            }
            var btns = Ext.ComponentQuery.query('splitbutton[purpose=alnheader]')
            btns.forEach(clearIcon);
        }

        var menuHandler=function(item) {
            var btn = item.up('splitbutton'),
                sort = btn.itemId + item.sortParam;
            if (this.m_sort !== sort) this.m_sort = sort;
            else delete this.m_sort;
            
            clearIcons();
            if (this.m_sort) btn.setIconCls(item.iconCls  + '_button');

            this.m_Align.pingClick(MultiAlignView.area.sortColumn);
            this.m_Align.reload();
        };

        this.m_ColumnTable.forEach(function(c) {
            if (!c.order) return;
            var cfg = Ext.clone(c.cfg);
            c.elemHead = pHead.add(cfg);
            if (cfg.name != undefined) {
                c.elemHead.add(Ext.create('Ext.Container', {
                    renderTo: Ext.getBody(),
                    itemId: c.id + 'cntr',
                    width: cfg.width,
                    separateArrowStyling:true,
                    items: [{
                            xtype: 'splitbutton',
                            purpose: 'alnheader',
                            text: cfg.name,
                            textAlign:'left',
                            tooltip: cfg.tooltip,
                            width: cfg.width,
                            itemId: c.id,
                            arrowVisible:false,
                            iconAlign: 'right',
                            iconCls: ((app.m_sort==c.id)||(app.m_sort==c.id+':a'))? 'xsv-sort_asc_button': (app.m_sort==c.id+':d' )?'xsv-sort_desc_button':null,
                            menu      : [
                                {text: 'Sort Ascending', iconCls: 'xsv-sort_asc', sortParam: '', handler:  menuHandler, scope: this.m_App},
                                {text: 'Sort Descending', iconCls: 'xsv-sort_desc', sortParam: ':d', handler:  menuHandler, scope: this.m_App}
                            ],
                            listeners: {
                                click: function(btn) {
                                    var curr_icon = btn.iconCls;
                                    clearIcons();
                                    app.m_sort = btn.itemId;

                                    if (curr_icon == 'xsv-sort_asc_button') {
                                        app.m_sort += ':d';
                                        btn.setIconCls('xsv-sort_desc_button');
                                    } else {
                                        btn.setIconCls('xsv-sort_asc_button');
                                    }
                                    app.pingClick(MultiAlignView.area.sortColumn);
                                    app.m_Align.reload();
                                },
                                mouseover: function(item) { item.setArrowVisible(true); },
                                mouseout: function(item) { item.setArrowVisible(false); }
                            }
                    }]
                }));
            }
            switch (c.id) {
                case 'aln':
                    aln = c;
                    cfg.html = cfg.html.replace('head_', '');
                    cfg.flex = 1;
                break;
//                case 'pi': case 'c': case 'mm': 
//                    cfg.tooltip = 'Not available without anchor/consensus is set/shown'; 
//                break;
                case 'x': this.m_ExpandCol = c;
            } 
            c.elem = pRows.add(cfg);
        }, this);
        this.getBodyDiv();
        this.rowsViewHead = aln.elemHead;
        this.rowsView = aln.elem;
        this.rowsViewHead.getEl().on(eventHandlers);
        this.rowsView.getEl().on(eventHandlers);
        this.rowsViewHead.getEl().dom.onmouseleave = leave;
        this.rowsView.getEl().dom.onmouseleave = leave;
        eventHandlers.pointerup = this.onPointerUp;
        delete eventHandlers.contextmenu;
        
        var expandCol = this.m_ExpandCol || {};
        if (expandCol.order) {
            expandCol.elemHead.getEl().on(eventHandlers);
            expandCol.elem.getEl().on(eventHandlers);
            expandCol.elemHead.getEl().dom.onmouseleave = leave;
            expandCol.elem.getEl().dom.onmouseleave = leave;
        }
    },

    getColumns: function(def, nowidth) {
        var str = '',
            ct = [];
        for (var id in this.defaultColumnTable) ct.push({id: id, cfg: this.defaultColumnTable[id]});
        if (!def && this.m_ColumnTable) ct = this.m_ColumnTable;
        ct.forEach(function(c) { if (c.order) str += c.id + (nowidth || c.cfg.width == undefined ? ',' : (':' + c.cfg.width + ',')); });
        return str.slice(0, -1);
    },
    
    setColumns: function(cols, keep) {
        if (typeof cols == 'string' && cols.length) cols = cols.split(',');
        cols = cols || [];
        var ct = [],
            alnRows = this.m_App.m_AlignRows;
        if (!cols.length || !this.m_ColumnTable || !keep) {
            for (var id in this.defaultColumnTable) {
                var c = {id: id, cfg: Ext.clone(this.defaultColumnTable[id])};
                if (c.cfg.hidden) {
                    if (!alnRows) continue;
                    delete c.cfg.hidden;
                    c.order = 0;
                }
                ct.push(c);
            }
            this.m_ColumnTable = ct;  
        }
        else ct = this.m_ColumnTable; 
        for (var i = 0; i < cols.length; i++) {
            var col = cols[i].split(':');
            var c = ct.find(function(c) { return c.id == col[0]; });
            if (!c) continue;
            c.order = i + 1;
            if (col[1]) {
                var w = parseInt(col[1]);
                if (w == 0) c.order = 0; else c.cfg.width = w;
            }
        }
        if (cols.find(function(c) { return c == 'aln'; }))
            ct.sort(function(c, n) { return (c.order || 1000) - (n.order || 1000); });
        else // default order
            ct.forEach(function(c, i) { if (c.cfg.width !== 0 && c.order != 0) c.order = 1; });
        var app = this.m_App;
        if (app.m_sort) {
            var s = app.m_sort.split(':');
            delete app.m_sort;
            if (ct.find(function(c) { return c.order && c.cfg.sortable && c.id == s[0]; })) 
                app.m_sort = s[0] + ':' + (s[1] != 'd' ? 'a' : 'd');
        }
        this.m_columnIDs = '|';
        this.m_ColumnTable.forEach(function(c) { if (c.order) this.m_columnIDs += c.id + '|'; }, this);

        this.initColumns();
    },

    syncToLocator: function() {
        if (!this.m_Locator) return;
        var from = this.m_AlignStart,
            len = this.m_AlignLen,
            panorama = this.m_App.m_Panorama;
        if (!this.m_Locator.m_ResizeRight) {
            if (this.isReversed)
                from = this.m_AlignStop - panorama.toSeq(this.m_Locator.getRight(true));
            else 
                from += panorama.toSeq(this.m_Locator.getLeft(true));
        }
        if (!this.m_Locator.m_Scroll)  len = panorama.toSeq(this.m_Locator.getWidth());

        var new_len  = Math.max(len,
                                Math.floor(this.getAlignViewWidth() * MultiAlignView.MinBpp));
        var new_from = from;
        if (new_len != len) {
            new_from = from + Math.round((len - new_len)/2);
        }

        var delta = Math.round((this.m_ScrollPix - new_from)*this.m_AspectPixToSeq);
        var new_pos = this.m_ScrollPix + delta;

        var screen_width = this.getAlignViewWidth();
        new_pos = Math.min(0, new_pos);
        new_pos = Math.max(new_pos, screen_width-this.m_Width);
        delta = new_pos - this.m_ScrollPix;
        this.m_ScrollPix = new_pos;
        var preload_margin = this.m_Width/10;
        this.m_ImageFromSeq = this.m_ImageFromSeq - Math.round(delta*this.m_AspectPixToSeq)-1;

        this.m_locatorAction = true;
        this.clearPageData();
        this.loadData(new_from, new_len, true);
    },
    
    checkLocatorWidth: function(width) {
        ///var len = this.m_App.m_Panorama.toSeq(width+3);
        //return MultiAlignView.MinBpp < len/this.getAlignViewWidth();
        return true;
    },

    clearHistory:  function() {
        this.m_History.length = 0;
        this.updateHistoryButtons();
    },

    clearPageData: function(full) {
        if (full) {
            var rmFunc = 'remove' + (Ext.isIE ? 'Node' : '');
            Ext.query('div[data-msa' + this.m_Idx + ']').forEach(function(el){el[rmFunc]();});
        }
        (this.rowPages || []).forEach(function(pg) { 
            if (pg.image) pg.image.style.opacity = 0.3;
            delete pg.alin_info;
        });
    },


    getPortalLink: function(rec, logarea) {
        // IE does not support string.startsWith, polyfill: 
        if (!String.prototype.startsWith) { 
            String.prototype.startsWith = function(searchString, position) {
                return this.substr(position || 0, searchString.length) === searchString;
           }; 
        }
    
        var pLink;
        if (rec.d.startsWith("SRA:")) { 
            pLink = "https://trace.ncbi.nlm.nih.gov/Traces/sra/?display=reads&run=";
            pLink += rec.d.substr(4);
        } else {
            pLink = MultiAlignView.webNCBI + (this.m_App.isProtein() ? 'protein/' : 'nuccore/');
            pLink += rec.d;
        }
        return pLink;
    },

    openFullView: function(area) {
        this.pingClick(area || MultiAlignView.area.linkToView);
        this.m_App.getLinkToThisPageURL(function(link) {
            window.open(link);
        }, 'full');
    },

    saveToHistory: function(title) {
        var MAX_HISTORY_LENGTH = 30;
        var range = this.toSeq();
        var anchor = this.m_App.getMaster();
        // save current parameters
        this.m_History.unshift({ anchor: anchor,
            range: range,
            title: title || ((anchor || "No anchor") + ' (' + (range[0] + 1) + '-' + (range[1] + 1) + ')')});
        this.m_History.splice(MAX_HISTORY_LENGTH);
        this.updateHistoryButtons();
    },
    
    stepHistory: function(remove){
        var history = this.m_History.shift();
        if (!remove && history) {
            this.clearPageData();
            if (history.anchor == this.m_App.m_Anchor) this.loadData(history.range[0], history.range[2]);
            else this.m_App.setMaster(history.anchor, true, history.range);
        }
        this.updateHistoryButtons();
    },

    updateHistoryButtons: function() {
        var btn_prev = this.m_View.down('#back_button');
        if (!btn_prev) return;
        var tooltip = 'Back';
        if (this.m_History.length) {
            btn_prev.enable();
            tooltip += ' to ' + this.m_History[0].title;
        } else btn_prev.disable();
        btn_prev.setTooltip(tooltip);
    }
}) }) ();
/*  $Id: app.js 46038 2021-01-21 16:39:16Z shkeda $
 * ===========================================================================
 *
 *                            PUBLIC DOMAIN NOTICE
 *               National Center for Biotechnology Information
 *
 *  This software/database is a "United States Government Work" under the
 *  terms of the United States Copyright Act.  It was written as part of
 *  the author's official duties as a United States Government employee and
 *  thus cannot be copyrighted.  This software/database is freely available
 *  to the public for use. The National Library of Medicine and the U.S.
 *  Government have not placed any restriction on its use or reproduction.
 *
 *  Although all reasonable efforts have been taken to ensure the accuracy
 *  and reliability of the software and data, the NLM and the U.S.
 *  Government do not and cannot warrant the performance or results that
 *  may be obtained by using this software or data. The NLM and the U.S.
 *  Government disclaim all warranties, express or implied, including
 *  warranties of performance, merchantability or fitness for any particular
 *  purpose.
 *
 *  Please cite the author in any work or product based on this material.
 *
 * ===========================================================================
 *
 * Authors:  Vlad Lebedev, Maxim Didenko, Victor Joukov
 *
 * File Description:
 *
 */

MultiAlignView.MinBpp = 1 / 24;

MultiAlignView.fireEvent = function(eName, elemID){
    var elem = document.getElementById(elemID);
    if (document.createEvent) {
        var e = document.createEvent('HTMLEvents');
        e.initEvent(eName, false, false);
        elem.dispatchEvent(e);
    } else elem.fireEvent(eName);
};


/********************************************************************/
//////////////////////////////////////////////////////////////////////
// MultiAlignView.App
/********************************************************************/

Ext.define('MultiAlignView.App', {
    extend: 'Ext.util.Observable',
    // private statics

//    return {

    constructor: function(div_id) {
        Ext.enableAria = false;
        Ext.enableAriaButtons = false;
        Ext.enableAriaPanels = false;
        var sm_ResizeWatcher = null;
        var rel = Ext.get(div_id);
        if (rel)
            rel.addCls("MultiAlignViewerApp");
        else
            throw "A div element containing MultiAlignViewer should have an id attribute";

/*    
        function Resizer(w, h) {
            for (var i = 0; i < MultiAlignView.App.sm_Apps.length; i++) {
                MultiAlignView.App.sm_Apps[i].doWindowResize(w, h);
            }
        };*/
    
        function onWindowResize(w, h) {
            var rw = w;
            var rh = h;
            if (sm_ResizeWatcher) {
                clearTimeout(sm_ResizeWatcher);
                sm_ResizeWatcher = null;
            }
            sm_ResizeWatcher = Ext.defer(function(w, h) {
                for (var i = 0; i < MultiAlignView.App.sm_Apps.length; i++) {
                    MultiAlignView.App.sm_Apps[i].doWindowResize(w, h);
                }
            }, 500,this,[rw,rh]);
        };

        function onWindowScroll() {
            for (var i = 0; i < MultiAlignView.App.sm_Apps.length; i++) {
                if (MultiAlignView.App.sm_Apps[i].m_Align) {
                    MultiAlignView.App.sm_Apps[i].m_Align.checkDataAvail();
                }
            }
        }

        Ext.on('resize', onWindowResize);
        Ext.on('scroll', onWindowScroll);
        
        this.m_DivId = div_id;
        this.m_DivCtrlId = this.m_DivId + 'Controls';
        this.m_DivJSId = this.m_DivId + 'JS';
        this.m_DivTitle = this.m_DivId + 'Title';
        this.m_DivTitleID = this.m_DivId + 'TitleID';
        this.m_InitialLoading = false;

        this.m_Idx = MultiAlignView.App.sm_Apps.push(this) - 1;

        this.m_tooltipsManager = new tooltipsManager(this);
        this.callParent(arguments);
    },

    // public static
    statics: {
        
    sm_Apps: [],

    simpleAjaxRequest: function(cfg) {
        cfg.xhrFields = {withCredentials: true};
        Ext.applyIf(cfg, {type: 'POST'});
        cfg.crossDomain = true;
        Ext.applyIf(cfg, {dataType: MultiAlignView.jsonType});
        jQuery.support.cors = true;
        try {
            return jQuery.ajax(cfg);
        } catch (e)
        { return e;};
    },
    
    // API

    getApps: function() {
        return MultiAlignView.App.sm_Apps;
    },

    findAppByIndex: function(app_idx) {
        for(var i = 0; i < MultiAlignView.App.sm_Apps.length; ++i) {
            if (MultiAlignView.App.sm_Apps[i].m_Idx == app_idx) {
                return MultiAlignView.App.sm_Apps[i];
            }
        }
        return null;
    },

    findAppByDivId: function(div_id) {
        for(var i = 0; i < MultiAlignView.App.sm_Apps.length; ++i) {
            if (MultiAlignView.App.sm_Apps[i].m_DivId == div_id) {
                return MultiAlignView.App.sm_Apps[i];
            }
        }
        return null;
    },
    
    // end of API
    pingClickByIdx:  function(app_idx, logarea) {
        var app = this.findAppByIndex(app_idx);
        if (app) app.pingClick(logarea);
    },

    showLinkURLDlg:  function(app_idx, logarea) {
        var app = this.findAppByIndex(app_idx);
        if (app) app.showLinkURLDlg(logarea);
    },

    showFeedbackDlg: function(app_idx, logarea) {
        var app = this.findAppByIndex(app_idx);
        if (app) {
            if (logarea) app.pingClick(logarea);
            app.showFeedbackDlg();
        }
    },

    showPrintPageDlg: function(app_idx) {
        var app = this.findAppByIndex(app_idx);
        if (app) { app.showPrintPageDlg(); }
    }
    }, // statics
    
    // API
    pingClick: function(area, event) {
        var obj = {jsevent: 'click', 'msa-area': area};
        if (event) obj['msa-event'] = event;
        this.ping(obj);
    },
    
    tmp_pingArgs: [],
    ping: function(a) { // saving pings while NCBI instrumented page is loading
        var args = this.tmp_pingArgs;
        if (typeof ncbi !== 'undefined' && ncbi.sg.ping) {
            this.ping = function(obj) {
                obj.ncbi_app = 'msaviewer-js';
                obj['msa-appname'] = this.m_AppName;
                ncbi.sg.ping(obj);
            };
            if (MultiAlignView.doInitPing) {
                this.ping({'msa-browser': Ext.browser.name,
                    'msa-browser-version': Ext.browser.version.major, 'msa-os': Ext.os.name});
                delete MultiAlignView.doInitPing;
            }
            while (args.length) this.ping(args.shift());
            delete this.tmp_pingArgs;
            this.ping(a);
        } else {
            if (args.push(a) > 5) console.log('DROPPED PING: ' + JSON.stringify(args.shift()));
        }
    },

    getAlignRange: function() {
        return (this.m_Align && this.m_Align.m_AlignStart != undefined) 
            ? [this.m_Align.m_AlignStart, this.m_Align.m_AlignStop] 
            : [this.m_DataInfo.aln.b, this.m_DataInfo.aln.e];
    },

    getDataLength: function() { return this.m_Align.m_AlignLen; },
    getColoring: function() { return this.m_Coloring; },
    getColoringMethods: function() { return this.m_DataInfo.coloringMethods || []; },
    getMaster: function() { return this.m_Anchor; },
    getRows: function(fSelected) { return (this.m_Align)? this.m_Align.getRows(fSelected) : []; },
    getFullRowInfo: function(id) { return (this.m_AlignRows || []).find(function(row) { return row.id == id; }); },

    getRowInfo: function(row_id) {
        var parts = row_id.split(':');
        return {id:parts[0], start:parts[1], end:parts[2]};
    },
    
    selectRow: function(row_id, sel_unsel) {
        if (this.m_Align) this.m_Align.selectRow(row_id, sel_unsel);
    },

    setMaster: function(row_id, from_ui, range) {
        var panorama = this.m_Panorama,
            app = this,
            av = this.m_Align,
            vRange = av.toSeq(0);
        var src = av.m_Type;
        av.m_vHighlight.seqPos = null;
        if (this.m_Anchor && !this.isConsensus(this.m_Anchor))
            src = this.m_Anchor;
        var dst = row_id || av.m_Type;
        if (!row_id) {
            if (src == dst) range = range || vRange;
            if (this.m_ShowConsensus) 
                row_id = this.m_Anchor = this.m_ConsensusId;
            else
                this.m_Anchor = null;
        }

        var changeParams = function(default_row) {
            app.m_Anchor = row_id;
            var row = av.getRowInfo(row_id) || default_row;
            if (row) {
                av.m_AlignStart = row.b;
                av.m_AlignStop = row.e;
                av.m_AlignLen = row.e - row.b + 1;
                av.isReversed = av.m_AlignLen < 0;
            }
            if (panorama) panorama.updateView();
            if (from_ui) app.fireEvent('master_changed', app.m_Anchor);
            if (Ext.isIE) return;
            // updating AlignData (WASM)
            var params = { view: 'msa-config' };
            app.addURLParams(params);
            Ext.applyIf(params, {anchor: -1});
            if (!row_id) app.m_AlignRows.forEach(function(ar) { ar.mm = ar.c = ar.pi = '-'; });

            MultiAlignView.App.simpleAjaxRequest({ url: app.m_CGIs.Alignment, context: app, data: params,
                success: function(data, text) {
                    this.m_AlnDataKey = data.align_data_key;
                    this.updateAlignDataWASM();
                },
                error: function() { console.alert(arguments); }
            });
        }
        if (range) {
            changeParams();
            av.loadData(range[0], range[2]);
        } else
            this.mapCoords([vRange[0],vRange[1]], src, dst,
                function(p, default_row) {
                    changeParams(default_row);
                    if (!p) {
                        av.reload(true, true);
                        return;
                    }
                    var from = p[0].length == 1 ? p[0][0] : p[0][2];
                    var to = p[1].length == 1 ? p[1][0] : p[1][1];
                    if (from > to) { var t = to; to = from; from = t; }
                    var len = to - from + 1;
                    av.loadData(from, len);
            });
    },

    updateAlignDataWASM: function(callInfoLoaded) {
        try {
            if (!this.m_AlnDataKey) throw('Missing NetCache Key');

            if (this.m_AlignRows) {
                this.m_updatingAlignData = true;
//                this.m_AlignRows.forEach(function(ar) { delete ar.mm; delete ar.c; delete ar.pi; });
            }
            delete this.m_AlignTTInfo;
            deleteAlignment();
            setAlignDataURL(this.m_CGIs.NetCache + '?key=' + this.m_AlnDataKey);
            getAlignment().then(function(alnData) {
                if (!MultiAlignView.WASMModuleVersion) {
                    var v = alnData.versionInfo();
                    MultiAlignView.WASMModuleVersion = 'version: ' + v.version + '<br><span style="font-size:10px;">Revision ' + v.revision + ', date: ' + v.date + '</span>';
                    MultiAlignView.App.simpleAjaxRequest( {url: this.m_CGIs.Alignment + '?target=applog&webasm_module_version=' + v.version + '&webasm_module_revision=' +
                        v.revision + '&webasm_module_date=' + v.date});
                }
                this.m_AlignTTInfo = alnData;
                this.m_AlignRows = [];
                var rows = alnData.fetchRows();
                for (var i = rows.size(); i-- ;) this.m_AlignRows.unshift(rows.get(i));
                rows.delete();
                if (!this.m_Anchor) 
                    this.m_AlignRows.forEach(function(ar) { ar.mm = ar.c = ar.pi = 'n/a'; });
                else
                    this.m_AlignRows.forEach(function(ar) { 
                        let v = Number.parseFloat(ar.c);
                        if (isNaN(v) === false) ar.c = v.toFixed(2); 
                        v = Number.parseFloat(ar.pi);
                        if (isNaN(v) === false) ar.pi = v.toFixed(2);
                    });
                delete this.m_updatingAlignData;
                if (callInfoLoaded) this.infoLoaded();
                else this.m_Align.fillDelayedPages();
            }.bind(this));
        } catch(e) {
            this.ping({msaWASM: 'getAlingment', error: e});
        }
    },

    setColoring: function(coloring, from_ui) {
        this.m_Align.updateColoringIcon(this.m_Coloring, 'none');
        this.m_Coloring = coloring;
        this.m_Align.reload();

        if (from_ui) this.fireEvent('coloring_changed', this.m_Coloring);
    },

    setShowIdentical: function(id, from_ui) {
        this.m_ShowIdentical = !id;
        this.m_Align.reload();

        //if (from_ui) this.fireEvent('identity_changed', id);
    },


    mapCoords: function(coords, source, target, callback, dir) {
        if (!coords.length) {
            callback.call(true, []);
            return;
        }
        var params = {
            view    : 'msa-map',
            mapto   : target,
            mapfrom : source,
            coords  : coords.join(',')
        };
        if (typeof dir != "undefined") params.dir = dir;
        this.addURLParams(params);
        MultiAlignView.App.simpleAjaxRequest({url: this.m_CGIs.Alignment, context: this,/* dataType: 'JSON',*/
            data: params,
            success: function(data, text) {
                if (data.coords && data.coords.length)
                    callback.call(true, data.coords, {b: data.aln_start, e: data.aln_stop});
                else
                    callback.call(false);
            },
            error: function(data, text) { callback.call(false); }
        });
    },

    isProtein: function() {
        return this.m_DataInfo && this.m_DataInfo.acc_type == "protein";
    },

    isNucleotide: function() {
        return !this.m_DataInfo || this.m_DataInfo.acc_type != "protein";
    },
    
    // end of API

    addURLParams: function(params) {
        if (this.m_Key) params.key = this.m_Key;
        if (this.m_Coloring) params.coloring = this.m_Coloring;
        if (this.m_ColoringOpt) params.coloring_opt = this.m_ColoringOpt;
        if (this.GI) params.id = this.GI;
        if (this.m_Anchor) params.anchor = this.m_Anchor;
        if (this.m_AppName) params.appname = this.m_AppName;
        if (this.m_TrackConfig) params.track_config = this.m_TrackConfig;
        if (this.m_Tracks) params.tracks = this.m_Tracks;
        if (this.m_UploadedTracks.length > 0) {
            if (!params.tracks)
                params.tracks = '';
            params.tracks += this.m_UploadedTracks.join('');
        }
        params.datasource = this.m_DataSource;
        if (this.hasOwnProperty('m_ShowConsensus')) params.consensus = this.m_ShowConsensus ? 't' : 'f';
        params.identical  = this.m_ShowIdentical ? 't' : 'f';
        if (this.m_sort) params.sort = this.m_sort;
    },
    

    // public
    
//////////////////////////////////////////////////////////////////////////
// doWindowResize

    doWindowResize: function(w,h) {
        this.updateLayout();
        w = Ext.getViewportWidth();
        if (this.m_BrowWidth != w) {
            this.reloadAllViews();
            this.m_BrowWidth = w;
        }
    },

//////////////////////////////////////////////////////////////////////////
// reload:

    reload: function(rel_attr, keep_config) {
        if (this.m_Panorama)
            this.m_Panorama = this.m_Panorama.destroy();
        if (this.m_Align)
            this.m_Align = this.m_Align.destroy();

        var view = Ext.get(this.m_DivJSId)
        if (view) {
            view.remove();
            delete view;
        }
        view = Ext.get(this.m_DivCtrlId);
        if (view) {
            view.remove();
            delete view;
        }
        if (this.m_PermConfId) {
            var el = Ext.get(this.m_PermConfId);
            if (el) {
                var fc = el.first()
                if (fc)
                    fc.remove();
            }
        }
        this.load(rel_attr);
    },

//////////////////////////////////////////////////////////////////////////
// initLinks: initialize GI and data independent links, all other links
// are initialized in loadAccession
    initLinks: function() {
        if (!MultiAlignView.ExtIconLoading) {
            try {// getting path to ExtJS loading.gif
                MultiAlignView.ExtIconLoading = getComputedStyle(document.querySelector('.x-mask-msg-text'))['background-image'];
            } catch(e) {}
        }
        var prefix = MultiAlignView.base_url + 'cgi/';
        this.m_CGIs = {
            prefix:     prefix,
            NetCache:   prefix + 'ncfetch.cgi',
            Feedback:   prefix + 'feedback.cgi',
            Alignment:  prefix + 'alnmulti.cgi',
            Watchdog:   prefix + 'sv_watchdog.cgi'
        };
        if (this.m_hiddenOptions.search('use_jsonp') >= 0) MultiAlignView.jsonType = 'JSONP';
        else {
            MultiAlignView.jsonType = 'JSON';
            if (Ext.isIE) {
                MultiAlignView.App.simpleAjaxRequest({url: this.m_CGIs.Feedback, context: this,
                    success: function(data, text) { MultiAlignView.jsonType = 'JSON'; },
                    error: function(data, text) { MultiAlignView.jsonType = 'JSONP'; }
                });
            }
        }
        if (!this.m_AppName || this.m_AppName == 'no_appname') {
            if (!MultiAlignView.origHostName && !this.m_Embedded && MultiAlignView.standalone) this.m_AppName = 'ncbi_msaviewer';
            else {
                var newAppName = document.location.hostname;
                if (MultiAlignView.origHostName || (newAppName.search(/www|qa|test|blast/) != 0)) {
                    var msg = 'MSA Viewer was initialized with parameter <b>appname=' + this.m_AppName + '</b><br>';
                    Ext.Msg.show({title: 'Warning',
                        msg: msg + 'It will be substituted with the hostname: <b>' + newAppName + '</b>',
                        icon: Ext.Msg.WARNING,
                        buttons: Ext.Msg.OK
                    });
                }
                this.m_AppName = newAppName;
                this.m_appWarning = 'Uninitialized <b>appname</b> is set to <b>' + newAppName + '</b><br>';
           }
        }
    },


    loadDataSuccess: function(callback) {
        var frontpage_text = Ext.get('app-frontpage');

        if (this.GI || (this.m_Key && this.m_Key.length)) {
            if (frontpage_text) {
                frontpage_text.remove();
            }
            this.createAndLoadMainPanel(callback);
        } else {
            if (this.m_DivId) {
                var el = document.getElementById(this.m_DivId);
                while (el.children.length) {
                    el.removeChild(el.children[0]);
                }
            }
            if (frontpage_text) {
                frontpage_text.setStyle('display', 'block');
            }
        }
    },

    load: function(rel_attr, maxDelay) {
        if (typeof maxDelay === 'undefined') maxDelay = 1000;
        var interval = 3;
        var app = this;
        setTimeout(function() { // Delay to allow jQuery to get ready
            maxDelay -= interval;
            if (typeof UUD === 'undefined' && maxDelay > 0)
                app.load(rel_attr, maxDelay);
            else {
                app.parseParams(rel_attr);
                app.initLinks();
                if (app.m_OpenUploadDialog) {
                    delete app.m_OpenUploadDialog;
                    app.showUploadDialog(app.loadDataSuccess, app);
                } else
                    app.loadExtraData();
            }
        },interval);
    },


    getTrackObjects: function(all) {
        var tracks = [];
        return tracks;
    },


//////////////////////////////////////////////////////////////////////////
// clearParams:

    clearParams: function() {

        this.GI = 
        this.m_Anchor =
        this.m_Coloring = 
        this.m_ScoringOpt = 
        this.m_From = 
        this.m_To = 
        this.m_Align = 
        this.m_Panorama = null;
        delete this.m_ShowConsensus;
        this.m_ShowIdentical = false;

        this.m_Tracks = null;
        this.m_TrackConfig = null;
        this.m_UploadedTracks = [];
        this.m_DataSource = "";

        this.m_Key = null;

        this.m_hiddenOptions = '';
        this.m_userData = [];
        this.m_FindCompartments = false;

        this.m_Embedded = false;

        this.m_ExpandStr = "";
        this.m_HiddenStr = "";

        this.m_ViewRanges = [];
        delete this.m_AppName;

        delete this.m_Panel;
        this.m_Panel = null;
        // Dummy sequence/alignment info
        this.m_DataInfo = { id: "Alignment", title: "", id_full: "Alignment", length: -1, acc_type: 'DNA' };
        this.m_ItemID = null;

        this.m_QueryRange = null;

        this.m_GraphicExtraParams = {};

        this.m_Toolbar = {
            history: true,
            name: true,
            search: true,
            panning: true,
            zoom: true,
            modeswitch: true,
            download: true,
            tools: true,
            config: true,
            reload: true,
            edit:true,
            help: true
        };
    },

//////////////////////////////////////////////////////////////////////////
// parseParams:

    parseParams: function(rel_attr) {
        this.clearParams();
        var doc_location = document.location.href;
        this.m_AllViewParams = doc_location.split("?")[1] || '';
        this.m_AllViewParams = this.m_AllViewParams.replace(/#/, ''); // safety

        if (!rel_attr) {
            var rel = Ext.get(this.m_DivId);
            if (rel && rel.dom) {
                var aref = rel.first();
                if (aref && aref.dom && aref.dom.tagName == "A") {
                    rel_attr = aref.dom.href.slice(aref.dom.href.indexOf('?') + 1)
                    aref.remove();
                } else { // for compatibility with the old verions
                    rel_attr = rel.dom.getAttribute('rel');
                }
            }
        }
        if (rel_attr != null) {
            var href = this.m_AllViewParams;
            var keep = ''; 
            var pLst = ['parallel_render', 'extra_opts'];
            Ext.each(pLst, function(p){
                var idx = href.indexOf(p);
                if (idx < 0) return;
                keep += '&' + href.slice(idx).split('&')[0]
            });
            // We should not merge URL parameters in for embedded viewers.
            // Better is to parse rel_attr into parameter set first,
            // but this is reliable enough - equal sign in all other
            // places beyond parameter definition should be escaped
            this.m_AllViewParams = (/embedded=/.test(rel_attr))
                ? rel_attr
                : this.m_AllViewParams + '&' + rel_attr;
            this.m_AllViewParams += keep;
        }
        this.m_AllViewParams = Ext.util.Format.htmlDecode(this.m_AllViewParams);

        if (this.m_AllViewParams) {
            var p_array = this.m_AllViewParams.split('&');

            var sKeys= ['key', 'naa', 'tkey', 'rkey', 'expand',
                        'url', 'url_reload', 'rid', 'data', 'id', 'anchor', 'master', 'select',
                        'content',
                        'snp_filter',
                        'search', 'coloring', 'identical', 'consensus',
                        'tracks', 'track_config', 'datasource'];

            for (var i = 0; i < p_array.length; i++) {
                var pair = p_array[i]
                var p = pair.split("=");
                var the_key = p[0].toLowerCase();

                var val = (p[1] === undefined ? '' : unescape(p[1]));
                
                if (sKeys.indexOf(the_key) == -1) val = val.toLowerCase();
                
                switch (the_key) {
                    case 'id': this.GI = val; break;
                    case 'master': // synonym for anchor
                    case 'anchor': this.m_Anchor = val; break;
                    case 'coloring': this.m_Coloring = val; break;
                    case 'coloring_opt': this.m_ColoringOpt = val; break;
                    case 'consensus': this.m_ShowConsensus = val == 't' || val == 'true' || val == 1; break;
                    case 'identical': this.m_ShowIdentical = val == 't' || val == 'true' || val == 1; break;
                    case 'tracks': this.m_Tracks = val; break;
                    case 'track_config': this.m_TrackConfig = val; break;
                    case 'datasource': this.m_DataSource = val; break;
                    case 'f': case 'from': this.m_From = val; break;
                    case 't': case 'to':  this.m_To = val; break;
                    case 'sort': this.m_sort = val; break;
                    case 'gl_debug': if (val == '1' || val == 'true') this.m_GraphicExtraParams['gl_debug'] = 'true'; break;
                    case 'key': this.m_Key = val; break;
                    case 'naa': this.m_NAA = val; break; // like: naa=NA000000003,NA000000004, NA000000004:renderer_name
//                    case 'srz': this.m_SRZ = val; break; // like: srz=SRZ000200
//                    case 'depth_limit': this.m_DepthLimit = val;  break;
                    case 'find_comp': this.m_FindCompartments = val == "true" || val == "1" || val == "on"; break;
                    case 'data': val = decodeURIComponent(val); // literal data, URI component encoded
                    case 'rkey':
                    case 'rid':  
                    case 'url_reload': // the same like 'url' with check_cs = true 
                    case 'url': // like: url=www.ncbi.nlm.nih.gov/data.txt
                        this.m_userData.push([the_key, val]);
                        break;
                    case 'openuploaddialog': this.m_OpenUploadDialog = true; break
                    case 'embedded': this.m_Embedded = val == "true" || val == "1" || val; break;
                    case 'v': if(val.length) { this.m_ViewRanges = val.split(','); } break; // like: v=1000:6000,8000:18723
                    case 'expand': this.m_ExpandStr = val; break;
                    case 'hidden': this.m_HiddenStr = val; break;


                    case 'itemid': this.m_ItemID = val; break;
                    case 'extra_opts': this.m_hiddenOptions = val; break;
                    case 'iframe': this.m_iFrame = val; break;
                    case 'appname': if (val && val.length > 0) this.m_AppName = val; break;
                    case 'columns': if (val) this.m_columns = val.split(','); break;
                    case 'toolbar': if (!val) break;
                        var add = val.charAt(0) != '-';
                        var start = add ? 0 : 1;
                        if (add) this.m_Toolbar = {};
                        for (var j = start; j < val.length; j++) {
                            switch (val.charAt(j)) {
                                case 'b': this.m_Toolbar["history"] = add; break;
                                case 'n': this.m_Toolbar["name"] = add; break;
                                case 's': this.m_Toolbar["search"] = add; break;
                                case 'p': this.m_Toolbar["panning"] = add; break;
                                case 'z': this.m_Toolbar["zoom"] = add; break;
//                                case 'm': this.m_Toolbar["modeswitch"] = add; break;
                                case 'd': this.m_Toolbar["download"] = add; break;
                                case 't': this.m_Toolbar["tools"] = add; break;
                                case 'e': this.m_Toolbar["edit"] = add; break;
//                                case 'c': this.m_Toolbar["config"] = add; break;
                                case 'r': this.m_Toolbar["reload"] = add; break;
                                case 'h': this.m_Toolbar["help"] = add; break;
                            }
                        }
                        break;
                }
                // MultiAlignView.TM.renderStat = this.m_hiddenOptions.indexOf('render_stat') >= 0;

            } // for

        } // view

        var ncbi_portal_app = "ncbientrez";

        this.m_Portal =
            !this.m_Embedded
            && this.m_AppName
            && this.m_AppName.substring( 0, ncbi_portal_app.length ) == ncbi_portal_app
        ;

        var  cfg = [];
        if (this.m_Embedded) {
/*             var cfg_id = Ext.get(this.m_DivId+'_confdlg');
            if (cfg_id) {
                this.m_PermConfId = this.m_DivId+'_confdlg';
            }
            cfg = [{tag: 'div', id: this.m_DivJSId}];
            cfg = [{tag: 'div', cls: 'MultiAlignViewerJS', id: this.m_DivJSId}]; */
        } else {
            var tmpl = new Ext.Template(
                 '<a onClick="MultiAlignView.App.showLinkURLDlg('+this.m_Idx+', \'top-3\');" href="javascript:void(0)">Link To View</a> | ',
                 '<a onClick="MultiAlignView.App.showFeedbackDlg('+this.m_Idx+', \'top-0\');" href="javascript:void(0)">Feedback</a>'// | ',
            );

            cfg = [
                {tag: 'div', cls: 'MultiAlignViewerControls hidden_for_print', id: this.m_DivCtrlId, html:tmpl.apply()}
                //{tag: 'div', cls: 'MultiAlignViewerJS', id: this.m_DivJSId}
            ];
            window.onpopstate = function() { window.location.reload(); }
        }
        if (this.GI || this.m_userData.length || this.m_Key || this.m_OpenUploadDialog) {
            if(cfg.length > 0)
                Ext.DomHelper.insertBefore(this.m_DivId, cfg);
            Ext.DomHelper.append(this.m_DivId, {tag: 'div', cls: 'MultiAlignViewerJS', id: this.m_DivJSId});

            var view_config = {
                collapsible: !this.m_Embedded,
                minHeight: 300,
                height: Ext.get(this.m_DivId).getHeight(),
                renderTo: this.m_DivJSId,
                html:'<span id="msa_table_ruler" style="font-size:12px;white-space:nowrap;font-weight=normal;font-family=tahoma,arial,verdana,sana-serif;visibility:hidden"></span>' + 
                '<span id="string_ruler_unit"></span>', // FIXME: residue of trimToPix and visualLength
                header: false
            };
            // MSA-375: allow to define max-height
            // min-height and max-height can be set inline or via a class styles
            var maxHeight = parseInt(Ext.get(this.m_DivId).getStyle("max-height")),
                minHeight = parseInt(Ext.get(this.m_DivId).getStyle("min-height"));
            if(!isNaN(minHeight) && minHeight > 0)
                view_config.minHeight = minHeight;
            if(!isNaN(maxHeight))
                view_config.maxHeight = Math.max(minHeight, maxHeight);

            this.m_Panel = new Ext.Panel(view_config);
            this.m_Panel.add(new Ext.Panel({
                height: !this.m_OpenUploadDialog ? 60 : 1, border: false, itemId: 'msgPanel',  
                items: [{xtype:'displayfield', name: 'progress', itemId:'uploadMsg', value: '',
                         style: {color:'grey', "text-align": 'left', "margin-top":'10px', "margin-left":'6px'}},
                        {xtype:'displayfield', name: 'error', itemId: 'uploadError', value: '',
                         style: {color:'red', "text-align": 'left', "margin-top":'10px', "margin-left":'6px'}}]
            })).mask('Initializing...');
            this.m_Panel.updateLayout();
        }
    },
    
    resizeIFrame: function(height) {
        if (!parent || !this.m_iFrame) return;

        var app_div = Ext.get(this.m_DivId);
        var total_height = app_div.getHeight();
        if (Ext.isIE) total_height += 4;
        if (height && height > total_height) total_height = height;

        if (!MultiAlignView.m_parent){
            try {
                var elemid = parent.document.getElementById(this.m_iFrame);
            } catch(e) {
                var a = document.createElement('a');
                a.href = document.referrer;
                MultiAlignView.m_parent = a.origin || a.href.slice(0, a.href.indexOf(a.hostname,0) + a.hostname.length);
            }
        }
        if (elemid) elemid.height = total_height;
        else parent.postMessage(total_height, MultiAlignView.m_parent);
    },

//////////////////////////////////////////////////////////////////////////
// openNewWindowPOST(url, params) - open new window by POSTing 'params' to 'url'
//     url - URL to use for POST
//     params - object with parameters to pass in the POST request
    openNewWindowPOST: function(url, params) {
        var new_win = window.open('about:blank', '_blank');
        new_win.focus();
        var new_body = new_win.document['body'];
        var form = new_win.document.createElement('form');
        form.method = 'POST';
        for (var name in params) {
            if (!params.hasOwnProperty(name)) continue;
            var el = new_win.document.createElement('input');
            el.type = 'hidden';
            el.name = name;
            el.value = params[name];
            form.appendChild(el);
        }
        new_body.appendChild(form);
        form.action = url;
        form.submit();
    },


    createAndLoadMainPanel: function(callback) {
        this.m_BrowWidth = Ext.Element.getViewportWidth();
        Ext.fly(this.m_DivId).on({'contextmenu': this.onContextMenu, scope: this});
        this.loadAccession(callback);
    },

    onContextMenu: function(e) {
//        if (e.getTarget().id.search('sv-goto-box_') == 0) return;
        e.preventDefault();  // this prevents the default contextmenu to open in Firefox (linux)
        e.stopPropagation();
    },


    loadAccession: function(callback) {
        if (this.m_Panel && this.m_Panel.down('#msgPanel')) this.m_Panel.removeAll();
        if (!this.GI && !(this.m_Key && this.m_Key.length)) {
            return;
        }

        this.forEachView( function(view) {
            view.remove();
        } );
        if (this.m_Panorama)
            this.m_Panorama = this.m_Panorama.destroy();
        if (this.m_Align)
            this.m_Align = this.m_Align.destroy();

        this.m_InitialLoading = true;
        delete this.m_AlignRows;
        var params = { view: 'msa-config' };
        this.addURLParams(params);
//        delete params.consensus;
        MultiAlignView.App.simpleAjaxRequest({
            url: this.m_CGIs.Alignment, context: this, data: params,
            success: this.processCfgResponse,
            error: this.infoLoaded
        });
    },

    processCfgResponse: function(data, text) {
        if (data.job_status) {
            if (data.job_status == 'failed' || data.job_status == 'canceled') 
                this.infoFailed('<b>Request ' + data.job_status + '</b><br>' + data.error_message);
            else
                Ext.Function.defer(MultiAlignView.App.simpleAjaxRequest, 2000, this,
                    [{url:this.m_CGIs.Alignment + '?job_key=' + data.job_id, context: this,
                    success: this.processCfgResponse, error: this.infoFaled  }]);
            return;
        }
        this.m_DataInfo.aln = {b: data.aln_start, e: data.aln_stop, type: data.aln_type, total_rows: data.total_rows, total_height: data.total_height};
        this.m_DataInfo.acc_type = data.aln_type;
        if (data.coloring_methods !== undefined)
            data.coloring_methods.forEach(function(cm) { cm.iconCls = 'none'; });
        this.m_DataInfo.coloringMethods = data.coloring_methods;
        if (data.tracks && !this.m_TrackConfig) this.m_TrackConfig = data.tracks;
        if (data.consensus_id) this.m_ConsensusId = data.consensus_id;
        if (this.m_Anchor == -1) {
            delete this.m_Anchor;
            this.m_ShowConsensus = false;
        }
        else {
            this.m_Anchor = this.m_Anchor || data.anchor_id || null;
            if (!this.hasOwnProperty('m_ShowConsensus')) this.m_ShowConsensus = data.hasOwnProperty('consensus_id');
        }
        this.m_PredefinedConsensus = data.predefined_consensus || false;
        if (MultiAlignView.AlignDataVersion == data.align_data_ver) {
            if (data.align_data_key && !Ext.isIE) {
                this.m_AlnDataKey = data.align_data_key;
                this.updateAlignDataWASM(true);
                return;
            }
        } else {
            MultiAlignView.App.simpleAjaxRequest( {url: this.m_CGIs.Alignment + '?target=applog&msg="Front-end (ver.' + MultiAlignView.AlignDataVersion
              + ') and Back-end (ver.' + data.align_data_ver + ') versions mismatch"'});
        }
        this.infoLoaded();
    },

    infoFailed: function(data, text, res){
        var msg = 'An internal error has occurred that prevents Multiple Sequence Alignment Viewer from displaying.<br> Technical details (config error): '
        if (typeof data === 'string') {
            msg = 'MSA config error: ' + data;
        } else {
            if (typeof data === 'object') {
                var dd = MultiAlignView.decode(data);
                msg += dd.msg || dd.statusText || dd.error_message;
            } else msg += text;
        }
        this.m_Panel.getEl().insertHtml("afterBegin", msg);
    },


    infoLoaded: function() {

        if (!this.m_Embedded && this.m_DataInfo.title)
            document.title = this.m_DataInfo.id + ': ' + this.m_DataInfo.title;

        var title_place = Ext.get(this.m_DivTitle);
        if (title_place) title_place.update(this.m_DataInfo.title);

        var title_id = Ext.get(this.m_DivTitleID);
        if (title_id) title_id.update(this.m_DataInfo.id_full);

        this.m_Panel.setTitle(this.m_DataInfo.id);
        this.m_SeqLength = this.m_DataInfo.length;

        if (!this.m_Embedded || this.m_Embedded == 'full') {
            this.createPanorama();
        }

        var from, to;
        if (this.m_From != null && (this.m_From == "begin" || this.m_From == "begining")) this.m_From = null;
        if (this.m_To != null && this.m_To == "end") this.m_To = null;
        if (this.m_From != null) {
            from = NCBIGBUtils.stringToNum(this.m_From) - 1;
        }
        if (this.m_To != null) {
            to = NCBIGBUtils.stringToNum(this.m_To) - 1;
        }

        if (this.m_QueryRange) {
            var overhang = Math.round(0.15 * (this.m_QueryRange[1] - this.m_QueryRange[0]));
            this.m_ViewRanges = [Math.max(0, this.m_QueryRange[0] - overhang) + ":" +
            Math.min(this.m_SeqLength - 1, this.m_QueryRange[1] + overhang)];
        }

        // fix for old Portal format
        if (this.m_ViewRanges.length == 1 && this.m_ViewRanges[0].indexOf('begin') != -1) {
            this.m_ViewRanges = []; // ignore cases such as begin..end
        }
        if (this.m_ViewRanges.length == 0 && typeof from != 'undefined' && typeof to != 'undefined') {
            this.m_ViewRanges[0] = (from + 1) + ':' + (to + 1);
        }
        this.updateLayout();
        ///////////////////////////////////////////////////////////////////////////
        // Create alignment view
        var alview = this.m_Align = new MultiAlignView.Alignment(this);
        if (this.m_ViewRanges.length > 0) {
            var the_r = this.m_ViewRanges[0];
            var range;

            if (the_r.indexOf(':') != -1) range = the_r.split(':');
            if (the_r.indexOf('..') != -1) range = the_r.split('..');
            if (the_r.indexOf('-') != -1) range = the_r.split('-');
            var zs = range[1] == 'zs';
            range = this.decodeRange(range);
            alview.m_FromSeq = range[0];
            alview.m_LenSeq = range[1] - range[0] + 1;
            //        alview.m_LenSeq  = range[1];
            if (zs) {
                alview.m_LenSeq -= Math.floor(415 * MultiAlignView.MinBpp); // adjust to align viewer borders
            }
        }
        alview.m_AlignStart = this.m_DataInfo.aln.b;
        alview.m_AlignStop = this.m_DataInfo.aln.e;
        alview.m_AlignLen = this.m_DataInfo.aln.e - this.m_DataInfo.aln.b + 1;
        if (this.m_ExpandStr) {
            alview.m_Expand = this.m_ExpandStr.split(',');
        }
        if (this.m_HiddenStr) {
            var HiddenArr = this.m_HiddenStr.split(',');
            alview.m_HiddenSet = new Set(HiddenArr);
        }
        else
        {
            alview.m_HiddenSet.clear();
        }
        alview.createPanel();

        acc_elements = Ext.query('[aria-owns]:not([aria-owns=""])', Ext.get(this.m_DivId));
        for (var i = 0; i < acc_elements.length; i++) acc_elements[i].removeAttribute("aria-owns");
    },


//////////////////////////////////////////////////////////////////////////
// notifyViewLoaded:

    notifyViewLoaded: function(view) {
        if(view != this.m_Panorama) {
            this.fireEvent('graphical_image_loaded', view);
        } else {
            this.fireEvent('panorama_image_loaded', view);
        }
        if (this.m_InitialLoading) {
            var loading_finished = true;
            this.forEachView(function(v) { loading_finished = loading_finished && !v.isLoading(); });
            if (loading_finished) {
                this.m_InitialLoading = false;
            }
            // we need to reload the panorama image in case if the browser added vscroll bar
            if (this.m_Panorama && this.m_Panorama.getWidth() != this.m_Panorama.getBodyWidth()) {
                this.m_Panorama.updateView();
            }
        }
    },

    isConsensus: function(id) { return id == this.m_ConsensusId; },
    moveTo: function(from, len) { this.m_Align.moveTo(from, len, {from_ui: false}); },

//////////////////////////////////////////////////////////////////////////
// addView:

    addView: function(cfg) {
        var view  = this.m_Panel.add(cfg);
        this.m_Panel.updateLayout();
        return view;
    },

    /** get app panel */
    getPanel: function(){
        return this.m_Panel;
    },
    
//////////////////////////////////////////////////////////////////////////
// updateLayout:
    updateLayout: function() {
        if (this.m_Panel) {
            var bottom = Ext.get(this.m_DivId).getAttribute('data-bottom');
            if (bottom != null) {
                this.m_Panel.setMaxHeight(Ext.getViewportHeight() - this.m_Panel.getY() - bottom);
                if (this.m_Align) this.m_Align.adjustViewPanels();
            }
            this.m_Panel.updateLayout();
         }
    },

    viewIsClosing: function(view) {  },
    removeView: function(view) { },

//////////////////////////////////////////////////////////////////////////
// createPanorama:

    createPanorama: function() {
        this.m_Panorama = new MultiAlignView.Panorama(this);
        this.m_Panorama.updateView();
    },

//////////////////////////////////////////////////////////////////////////
// loadPanoramaImage:

    loadPanoramaImage: function() {
        if (this.m_Panel && this.m_Panorama) {
            this.m_Panorama.updateView();
        }
    },

    getPanoramaHeight: function() { return this.m_Panorama ? this.m_Panorama.getHeight() : 0; },
    getPanoramaWidth: function() { return this.m_Panorama ? this.m_Panorama.getWidth() : 0; },

    updateLocator: function(view) {
        if (view.isPanorama() || view.isLoading()) return;

        var locator = view.m_Locator,
            panorama = this.m_Panorama;
        if (locator && panorama) {
            if (!panorama.isLoading()) {
                var range = view.toSeq();
                range[0] = view.isReversed ? view.m_AlignStop - range[1] : range[0] - view.m_AlignStart
                locator.setLeft(panorama.toPix(range[0]));
                locator.setWidth(this.m_Panorama.toPix(range[2]));
                locator.setHeight(this.getPanoramaHeight());
            } else {
                Ext.Function.defer(this.updateLocator, 50, this, [view]);
            }
        }
    },



//////////////////////////////////////////////////////////////////////////
// forEachView:

    forEachView: function(fn, scope) {
        var v = this.m_Align;
        if (v) fn.call(scope || v, v);
        v = this.m_Panorama;
        if (v) fn.call(scope || v, v);
    },

//////////////////////////////////////////////////////////////////////////
// decodeRange:
// returns 0 - based range

    decodeRange: function(range) {
        var from = NCBIGBUtils.stringToNum(range[0])-1;
        var to = 0;
        if (!from) from = 0;
        if (this.m_SeqLength >= 0 && from >= this.m_SeqLength) from = 0;
        if (range[1] == 'zs') {
            var len = Math.floor((this.m_Panel.body.getWidth()-10) * MultiAlignView.MinBpp);
            to = from+len-1;
        } else {
            to = NCBIGBUtils.stringToNum(range[1])-1;
        }
        if (this.m_SeqLength >= 0) {
            if (!to) to = this.m_SeqLength;
            to = Math.min(to, this.m_SeqLength - 1);
        }
        return [from, to];
    },

    // Keep pos or range regex in one place
    splitPosOrRange: function(s) {
        s = s.replace(/[, ]/g, '');
        return s.match(/^([-+]?\d+(?:\.\d+)?[km]?)(?:(-|to|\.\.+|:|\/|_)([-+]?\d+(?:\.\d+)?[km]?))?$/i);
    },


//////////////////////////////////////////////////////////////////////////
// isPosOrRange:
    isPosOrRange: function(s) {
        return this.splitPosOrRange(s) != null;
    },

//////////////////////////////////////////////////////////////////////////
// isExplicitPosOrRange:
//     pos0, sep, pos1 - parts of a range split by pattern
//     returns true if numerals have a sign. e.g. -12:+24, or +35..-20
    isExplicitPosOrRange: function(pos0, sep, pos1) {
        var fc0 = pos0.charAt(0);
        var fc1;
        if (pos1 && pos1.length > 0 && sep !== '/') fc1 = pos1.charAt(0);
        return !((fc0 != '+' && fc0 != '-') || (fc1 && fc1 != '+' && fc1 != '-'));
    },

//////////////////////////////////////////////////////////////////////////
// convertRelativePosition:

    convertRelativePosition: function(pos_str) {
        var pos = NCBIGBUtils.stringToNum(pos_str);
        if (!isNaN(pos))
            return this.posToGlobal(pos);
        return pos;
    },

//////////////////////////////////////////////////////////////////////////
// posToLocal: convert backend 0-based global coordinate to
//     local, taking into account strand
    posToLocal: function(pos, flip) {
        if (pos >= 0) pos += 1;
        return pos;
    },

//////////////////////////////////////////////////////////////////////////
// posToGlobal: convert 1-based coordinate relative to origin and strand
//     to global 0-based backend coordinate
    posToGlobal: function(pos) {
        if (pos > 0) pos -= 1;
        return pos;
    },

//////////////////////////////////////////////////////////////////////////
// reloadAllViews:

    reloadAllViews: function(options) {
        this.m_Align.refresh(options);
        this.m_Panorama.refresh(options);
    },

    handleDataLoaded: function(uploader, dkey) {
        var meta_data = uploader.getMetadata();
        // if (this.load_params.rid_loaded && !this.GI) this.initRID(meta_data);
        if (dkey) this.addKey(dkey);
        var tracks = meta_data.tracks || [];
        // We need second pass to make sure if we don't have cleaned alignments
        // we use the original data
        for (var pass = 0; pass < 2; ++pass) {
            var data_found = false;
            for (var i = 0; i < tracks.length; ++i) {
                var track = tracks[i];
                if (track.annot_type == "align" && track.seq_ids &&
                    (pass > 0 || !this.m_FindCompartments || track.annot_name.indexOf("Cleaned Alignments -") == 0)) {
                    for (var j = 0; j < track.seq_ids.length; ++j) {
                        if (track.seq_ids[j].key) {
                            this.addKey(track.seq_ids[j].key);
                            data_found = true;
                        }
                    }
                } 
            }
            if (data_found) break;
        }
        // pickup annots as well
        for (var i = 0; i < tracks.length; ++i) {
            var track = tracks[i];
            if (track.annot_type == "ftable") {
                if (track.seq_ids) {
                    for (var j = 0; j < track.seq_ids.length; ++j) {
                        if (track.seq_ids[j].key) {
                            this.addKey(track.seq_ids[j].key);
                        }
                    }
                }
                if (track.track_type === undefined)
                    continue;
                var params = [];
                params.push("key:" + track.track_type);
                if (typeof track.track_subtype !== "undefined")
                    params.push("subkey:" + track.track_subtype);
                if (typeof track.annot_name !== "undefined")
                    params.push("annots:" + track.annot_name);
                this.m_UploadedTracks.push("[" + params.join(",") + "]");
            }            
        }
        
    },

//////////////////////////////////////////////////////////////////////////
// loadExtraData
//   callback object with success and/or failure defined

    loadExtraData: function(callback) {

        this.load_params = this.load_params || {};
        if (!this.m_userData.length) {
            this.loadDataSuccess(callback);
            return;
        }
        
        var config = { register_track: false, fastalign: true };
        if (this.GI) config['accession'] = this.GI;
        if (this.m_Key) { 
            config['prj_key'] = this.m_Key;
        } else if (this.load_params.key) {
            config['prj_key'] = this.load_params.key;
        }
        var data_item = this.m_userData.shift();
        if (data_item[0] == 'rkey') {// Fetch long RID with filters from NetCache key
            var params = {data_action: 'downloading', format: 'rids', key: data_item[1], fmt: "text/plain"};
            var processResponse = function(data) {
                    if (data.statusText == 'OK') this.m_userData.unshift(['rid', data.responseText]);
                    this.loadExtraData(callback);
            }
            this.AjaxRequest({url: this.m_CGIs.NetCache, data: params, context: this,
                success: processResponse,
                error: processResponse});
        } else {
            if (config.track_name) delete config.track_name;
            switch (data_item[0]) {
                case 'rid':
                    config.blast = {
                        rid: data_item[1], 
                        link_related_hits: this.m_FindCompartments
                    };
                    this.load_params.rid_loaded = true; // Mark that we loaded RID
                    break;
                case 'data':
                    config.data = data_item[1];
                    config.file_format = 'asn text';
                    break;
                case 'url_reload':
                    config.check_cs = true;
                    // FALLTHROUGH
                case 'url':
                    var url = data_item[1];
                    // convert to absolute using browser
                    var link = document.createElement("a");
                    link.href = url;
                    config.dataURL = link.href;
                    if (MultiAlignView.isFASTA(url)) config.file_format = 'align';
                    break;
            }
            var msg = 'Uploading your data';
            msg += ', please wait...'; 
            this.showMessage(msg);
//            this.m_Panel.items.items[0].getEl().mask('Uploading \"' + data_item[0] + '\"', 'x-mask-loading');
//            config.delaytest = 40;
            var app = this;
            try {
                var uploader = new UUD.FileUploader(config);
                var promise = uploader.getPromise();
                promise.fail(function() {
                    (app.m_Panel.down('#msgPanel') || {unmask: Ext.emptyFn}).unmask() ;
                    var errMsg = this.getErrors();
                    app.showMessage(errMsg, true);
                    var fbText = 'SViewer initial parameters: ' + app.m_AllViewParams + '\nError message: ' + this.getErrors();
                    Ext.MessageBox.show({title: 'User data loading error',
                        msg: errMsg,
                        buttons: {no: 'Continue', yes: 'Feedback', cancel: 'Cancel'},
                        icon: Ext.MessageBox.WARNING,
                        fn: function(btn) {
                            switch (btn) {
                                case 'yes': app.showFeedbackDlg(fbText, document.location.href); // "break" is missed to continue data loading
                                case 'no': app.loadExtraData(callback); break;
                            }
                        }});               
                });
                promise.done(function(tlist, dkey) {
                    app.handleDataLoaded(this, dkey);
                    var msg = 'Data uploaded';
                    app.showMessage(msg);
                    app.loadExtraData(callback);
                });
                var currTask = 'Uploading your data'
                promise.progress(function(progress) {
                    var task = progress.current_task;
                    if (task == "" || task == 'pending' || task == currTask) return;
                    app.showMessage(currTask = task);
                });
                uploader.upload();
            } catch(e) { app.showMessage('Unable to upload data: ' + e.message, true); } 
        }
    },
    

    showMessage: function(msg, errorFlag) {
        this.m_Panel.down((errorFlag ? '#uploadError' : '#uploadMsg')).update(msg);
    },


    addKey: function(key) {
        if (typeof key == 'undefined') return;
        if (!this.m_Key || this.m_Key.length == 0) this.m_Key = key;
        else
            if (this.m_Key.search(key) == -1) this.m_Key += ',' + key;
    },

    initRID: function(from_cgi) {
        if (from_cgi['blast_query'] === undefined) return; // Can't do anything
        var blast_query_list = from_cgi['blast_query'];
        var blast_query = {};
        for (var i = 0; i < blast_query_list.length; i++) {
            var kv = blast_query_list[i];
            blast_query[kv.key] = kv.value;
        }
        this.GI = blast_query['id'];
        if (!this.m_QueryRange) {
            var beg = blast_query['beg'];
            var end = blast_query['end'];
            var querybeg = blast_query['querybeg'];
            var queryend = blast_query['queryend'];
            if (querybeg !== undefined  &&  queryend !== undefined) {
                // Convert to numbers
                querybeg = querybeg - 0;
                queryend = queryend - 0;
            }
            if (beg !== undefined  &&  end !== undefined) {
                beg = beg - 0;
                end = end - 0;
                var overhang = 0.15 * (end - beg);
                beg = Math.max(0, beg - overhang);
                end += overhang;
                beg = Math.round(beg);
                end = Math.round(end);
                this.m_ViewRanges = [ beg + ':' + end ];
            }
        }
    },

/*
    getGraphicViews: function() {
        var views = []
        this.baseURL(function(view) {
            if (view.isGraphic())
                views.push(view);
        });
        return views;
    },
*/

    AjaxRequest: function(cfg){

        if( !this.m_AjaxTrans ) this.m_AjaxTrans = [];

        cfg.callback = cfg.callback || function(arg) {};
        cfg.params = cfg.params || {};

        if( this.m_AppName && this.m_AppName.length > 0 ){
            cfg.params.appname = this.m_AppName;
        }

        var trans = this.m_AjaxTrans;

        cfg.callback = Ext.Function.createInterceptor(cfg.callback,
            function(opts, succsess, res) {
                if( opts.params.transId ){
                    trans.remove( opts.params.transId );
                    delete opts.params.transId;
                }
            });

        var transId = MultiAlignView.App.simpleAjaxRequest(cfg);
        if( transId ){
            cfg.params.transId = transId;
            trans.push( transId );
            return transId;
        }
    },


    getCustomToolTipTools: function(selection) {
        if (this.m_CustomSelectionHandler)
            return this.m_CustomSelectionHandler.getToolTipTools(selection);
        return null;
    },


    setCustomSelectionHandler: function(handler) {
        this.m_CustomSelectionHandler = handler;
    },


    addCustomFeatureFlags: function(cfg) {
        if (this.m_CustomSelectionHandler) {
            this.m_CustomSelectionHandler.addCustomFeatureFlags(cfg);
        }
    },

    eventHandlers: function(fn, obj) {
       // fn - 'on'|'un'
       obj = obj.scope ? obj : { scope: obj, pointermove: obj.onPointerMove, pointerup: obj.onPointerUp };
       this.m_Panel.el[fn](obj);
    },

    setTooltipPreprocessor: function(callback) {
        if (typeof callback === 'function') this.m_preprocessorTT = callback;
        else delete this.m_preprocessorTT;
    },


    watchdogStart: function(url, job_id, params) {
        this.watchdogStop();
        this.m_WatchUrl = url;
        this.m_WatchJobId = job_id;
        this.m_WatchJobParams = params;
        this.m_WatchTimeoutId = Ext.Function.defer(this.watchdogReport, 90000, this, ['No response']);
    },


    watchdogStop: function() {
        if (this.m_WatchTimeoutId ){
            clearTimeout(this.m_WatchTimeoutId);
            this.m_WatchTimeoutId = null;
        }
    },


    watchdogReport: function(reason) {
        this.watchdogStop();
        this.AjaxRequest({
            url: this.m_CGIs.Watchdog,
            data: {
                reason: reason,
                requrl: this.m_WatchUrl,
                reqparams: this.m_WatchJobParams,
                jobid: this.m_WatchJobId
            }
        });
    },

    setColumns: function(cols, keep) {
        this.m_Align.setColumns(cols, keep);
        this.m_Align.refresh();
    },

    saveFile: function(url, eventarea) {
        if (eventarea) this.pingClick(eventarea);
        var form = Ext.DomHelper.append(document.body, { tag : 'form', method : 'post', action : url });
        document.body.appendChild(form);
        form.submit();
        document.body.removeChild(form);
    },

    checkRange: function(strRange) {
        var splitPosOrRange = function(s) {
            s = s.replace(/[, ]/g, '');
            return s.match(/^([-+]?\d+(?:\.\d+)?[km]?)(?:(-|to|\.\.+|:|\/|_)([-+]?\d+(?:\.\d+)?[km]?))?$/i);
        }
        var convertPosition = function(pos_str) {
            var pos = NCBIGBUtils.stringToNum(pos_str);
            if (!isNaN(pos)) return this.posToGlobal(pos);
            return pos;
        }

        var parts = splitPosOrRange(strRange),
            view = this.m_Align;
        if (parts == null || !parts[3]) return 'No range specified';

        var begPos = this.convertRelativePosition(parts[1]),
            endPos = parts[3];
        if (parts[2] == "/") {
            var pad = NCBIGBUtils.stringToNum(endPos);
            endPos = begPos + pad;
            endPos -= pad;
        } else {
            endPos = this.convertRelativePosition(endPos);
            if (begPos > endPos) {
                var t = begPos;
                begPos = endPos;
                endPos = t;
            }
        }
        if (isNaN(begPos) || isNaN(endPos) || begPos < 0 || endPos < 0 
            || begPos == endPos || begPos < view.m_AlignStart || endPos > view.m_AlignStop) {
            return 'Invalid range: Alignment positions should be from '
                 + this.posToLocal(view.m_AlignStart) + ' to ' +  this.posToLocal(view.m_AlignStop);
        }
        return [begPos, endPos];
    }
});


/*  $Id: dlg.js 46168 2021-01-27 15:23:39Z shkeda $
 * ===========================================================================
 *
 *                            PUBLIC DOMAIN NOTICE
 *               National Center for Biotechnology Information
 *
 *  This software/database is a "United States Government Work" under the
 *  terms of the United States Copyright Act.  It was written as part of
 *  the author's official duties as a United States Government employee and
 *  thus cannot be copyrighted.  This software/database is freely available
 *  to the public for use. The National Library of Medicine and the U.S.
 *  Government have not placed any restriction on its use or reproduction.
 *
 *  Although all reasonable efforts have been taken to ensure the accuracy
 *  and reliability of the software and data, the NLM and the U.S.
 *  Government do not and cannot warrant the performance or results that
 *  may be obtained by using this software or data. The NLM and the U.S.
 *  Government disclaim all warranties, express or implied, including
 *  warranties of performance, merchantability or fitness for any particular
 *  purpose.
 *
 *  Please cite the author in any work or product based on this material.
 *
 * ===========================================================================
 *
 * Authors:  Vlad Lebedev, Maxim Didenko, Victor Joukov, Evgeny Borodin
 *
 * File Description:
 *
 */

Ext.define('MultiAlignView.UploadPanel', {
    extend: 'Ext.Panel',
    dirty: false,
    initComponent : function(){
        Ext.apply(this, {
            layout: 'border',
            itemId: 'uploadpanel',
            infoMsg: 'No informations or details',
            items:[{
                region: 'west', layout:'fit', width: 160, title:'Data Source',
                items: [{
                    xtype: 'treepanel', rootVisible: false, enableDD: false, lines: false,  autoScroll: false,
                    listeners: { itemClick: function(node, rec) {
                        this.uploadButt.disable();
                        this.updateDiffPart(rec.data.type, rec.data.text);
                    }, scope: this},
                    root: {
                        children: [
                            {text:'BLAST Results', type:'rid', iconCls:'xsv-ext_data', leaf:true},
                            {text:'Data File', type:'file', iconCls:'xsv-ext_data', leaf:true},
                            {text:'URL', type:'url', iconCls:'xsv-ext_data', leaf:true},
                            {text:'Text', type:'text', iconCls:'xsv-ext_data', leaf:true}
                    ]}
                }]
            },{
                frame:true,
                xtype:'form',
                region: 'center',
                hidden: false,
                itemId:'loaddatapanel',
                fileUpload: true,
                items:[                        
                    {xtype:'panel', layout: 'form', border: false, bodyStyle: {background: 'inherit'}},
                    {xtype:'displayfield', itemId: 'uploadMsg', value: '', width:'95%',
                        style: {color:'grey', 'white-space': 'nowrap'}},
                    {xtype:'displayfield', itemId: 'uploadError', value: '',
                        style: {color:'red', 'white-space': 'wrap'}},
                    {xtype: 'button', hidden: true, scope: this, handler: this.showErrorDetails,
                        id: 'msa-err_details_button_id'}
                ]
            }],
            buttons: [{
                text:'Upload', scope: this, itemId: 'uploadButton',
                disabled: true,
                handler: function(b, e) {
                    e.stopEvent();
                    var form = this.down('#loaddatapanel').getForm();
                    if (!form.isValid()) return;
                    if (form.isDirty() || this.dzfiles) {
                        this.submitData(form);
                    }
                    else {
                        this.showMessage(null, 'Inputs are empty or invalid!');
                    }
                    this.app.pingClick(MultiAlignView.area.uploadPanel + this.type);
                }
            }]
        });
        this.callParent(arguments);
        this.updateDiffPart('rid', 'BLAST Results');
        this.uploadButt = this.down('#uploadButton');
    },

    showMessage: function(msg, errMsg) {
        if (typeof msg == 'string') this.down('#uploadMsg').update(msg);
        if (typeof errMsg == 'string') this.down('#uploadError').update(errMsg);
    },

    showErrorDetails: function() {
        if (this.infoMsg == '') return;
        var mbw = new Ext.Window({
            title: 'Error details',
            renderTo: this.app.m_DivId,
            modal: true, layout:'fit',
            width: 400, height: 300});
        mbw.add(new Ext.FormPanel({ labelWidth: 1, autoScroll: true,
            items:[
               {xtype: 'displayfield', value: this.infoMsg, textalign: 'left'}],
        	   buttons:[{text: 'OK', handler: function() {mbw.close();}}]})
        );
        mbw.show();
    },
    Sec2Time: function(sec) {
        var hours   = Math.floor(sec / 3600);
        var minutes = Math.floor((sec - (hours * 3600)) / 60);
        var seconds = sec - (hours * 3600) - (minutes * 60);
        var time = '';
        if (hours > 0) 
            time = hours + ' hour' + ((hours > 1) ? 's ' : ' ');
        if (minutes > 0)
            time += minutes + ' minute' + ((minutes > 1) ? 's ' : ' ');
        if (seconds > 0)
            time += seconds + ' second' + ((seconds > 1) ? 's' : '');
        return time;
    },
    updateMessage: function() {
        this.currTime++;
        this.totalTime++;

        var msg = '<br>';
        msg += 'Total time: ' + this.Sec2Time(this.totalTime) + '<br>';
        for (var i = 0; i < this.tasks.length; i++)
            msg += this.tasks[i].task + ": " + this.tasks[i].time + " seconds<br>";
        msg += this.currTask + ": " + this.Sec2Time(this.currTime);
        if (this.percentage) {
            var time = this.Sec2Time(Math.round(this.currTime * (100/this.percentage - 1)));
            if (time.length > 0) 
                msg += " (" + time + " remaining)";
        }
        msg += '<br>';
        if (this.percentage) msg += 'Percentage: ' + this.percentage + '%<br>';
        this.showMessage(msg);
        Ext.defer(this.updateMessageWrap, 1000, this, []);
    },

    updateMessageWrap: function() {
        if (this.uploader) this.updateMessage("");
    },

    reset: function(panel) {
        if (this.dzfiles) {
            for (f in this.dzfiles) {
                this.dzfiles[f].dzfname.update('');
                this.dzfiles[f].inputFld.value = '';
            }
            delete this.dzfiles;
        }
        panel.getForm().setValues({rid:'', data: '', dataURL: ''});
    },

    cleanupUpload: function(msg) {
        delete this.uploader;
        this.showMessage(null, msg);
    },
    
    submitData: function(form, callback, scope) {
        this.currTime = this.totalTime = this.percentage = 0;
        this.currTask = 'uploading file';
        this.tasks = [];

        Ext.getCmp('msa-err_details_button_id').hide();
        this.uploadButt.disable();
        this.showMessage('', '');

        var config = { register_track: false, fastalign: true };
        
        var combo = this.down('#file_format');
        if (combo) combo.setDisabled(false);
        var fval = form.getValues();
        if (combo) combo.reset();
        for (v in fval) {
            var val = fval[v];
            if (typeof val == 'string' && val.length == 0) continue;
            config[v] = val;
        }
        var find_comp = config.find_comp || false;
        delete config.find_comp;
        var url_params = "";
        if (config.rid) {
            config.blast = {rid: config.rid, link_related_hits: find_comp};
            url_params = "rid=" + config.rid;
        } else {
            config.check_cs = true;
        }
        if (config.url) url_params = "url=" + config.url;

        this.app.load_params = this.app.load_params || {};
        // mark that we're loading RID
        if (config.rid) this.app.load_params.rid_loaded = true;
        
        var uPanel = this;
        if (callback) {
            this.exitCallback = {callback: callback, scope: scope};
        }
        uPanel.consError = console.error;
        console.error = function() {}
        var finalize = function(msg) {
            console.error = uPanel.consError || console.error;
            delete uPanel.consError;
            uPanel.cleanupUpload(msg);
            if (!msg) {
                var msg = 'Data uploaded';
                uPanel.showMessage(msg);
                uPanel.app.m_Uploaded = true;
                if (url_params)
                    uPanel.app.m_UrlParams = url_params;
                else
                    uPanel.app.m_UrlParams = "key=" + uPanel.app.m_Key;
            }
            uPanel.reset(uPanel.down('#loaddatapanel'));
            if (uPanel.exitCallback) {
                var tmpobj = uPanel.exitCallback;
                delete uPanel.exitCallback;
                tmpobj.callback.call(tmpobj.scope);
            }
        }

        if (this.dzfiles) config.file = this.dzfiles.datafile;
        try {
            this.uploader = new UUD.FileUploader(config);
            var promise = this.uploader.getPromise();
            promise.fail(function() {
                var msg = [];
                this.getErrors().forEach( function(err) { 
                    msg.push(err.replace("\n", "<br>"));
                });
                finalize('Failed to upload data: ' + msg.join('<br>'));
            });
            promise.done(function(tlist, dkey) {
                uPanel.app.handleDataLoaded(this, dkey);
                
                var errMsg = this.getErrors();
                if (errMsg.length) {
                    uPanel.infoMsg = '';
                    Ext.each(errMsg, function(msg, idx){
                        this.infoMsg +='# ' + (idx + 1) + '. ' + msg + '<br>';
                    }, uPanel);
                    
                    var bttn = Ext.getCmp('msa-err_details_button_id');
                    var bttxt ='Data parsing error details (' + errMsg.length + ')';
                    bttn.setText(bttxt);
                    bttn.show();
                }
                finalize();
            });
            promise.progress(function(progress) {
                if (progress.percentage) uPanel.percentage = progress.percentage;
                var task = progress.current_task;
                if (task == "" || task == 'pending' || task == uPanel.currTask) return;

                uPanel.tasks.push({task: uPanel.currTask, time: uPanel.currTime});
                uPanel.currTask = task;
                uPanel.currTime = 0;
            });
            this.uploader.upload();
        } catch(e) { finalize('Unable to upload data: ' + e.message); } 
    
        this.updateMessage();
    },

    updateDiffPart: function(type, title) {
        var uPanel = this;
        this.type = type;
        var ff = ['auto detect', 'alignment text (FASTA)', 'asn binary', 'asn text'];
        var fileUploadDisabled = Ext.isIE && !(Ext.isIE12 || Ext.isIE11 || Ext.isIE10);
        var manageButt = function(str) {
            uPanel.uploadButt[str.length ? 'enable' : 'disable']();
            return true;
        }
        var processFName = function(ffld, file) {
            file.inputFld = document.getElementById(ffld.getInputId());
            file.dzfname = uPanel.down('#dz_' + ffld.itemId);
            uPanel.dzfiles = uPanel.dzfiles || {};
            uPanel.dzfiles[ffld.itemId] = file;
            file.dzfname.update(file.inputFld.value = file.name);
            var combo = uPanel.down('#file_format');
            if (MultiAlignView.isFASTA(file.name)) combo.setValue('align').setDisabled(true);
            else if (combo.isDisabled()) combo.setDisabled(false).reset();
        }
        
        var updateDropZone = function(self) {
            var files = self.fileInputEl.dom.files;
            if (files.length == 0) {
                uPanel.down('#dz_' + self.itemId).update('');
                uPanel.uploadButt.disable();
            } else {
                processFName(self, files[0]);
                uPanel.uploadButt.enable();
            }
        };
        var helpTxt = fileUploadDisabled ? 'File upload is unavailable in Internet Explorer versions 9 and earlier' : '';
        if (MultiAlignView.jsonType == 'JSONP') {
            fileUploadDisabled = true;
            helpTxt = 'Local files uploading is currently unavailable for X-domain/IE configuration';
        }

        var diff_parts = {
            rid: [
                {xtype:'displayfield', value: 'Please enter NCBI BLAST request ticket (RID) then press Upload',
                     width:'95%',  style: {fontSize: '122%'} },
                {xtype:'textfield', hideLabel:true, emptyText:'Please enter Blast RID', name: 'rid', width:'99%',
                     validator: manageButt},
                {xtype:'checkbox', name: 'find_comp', height:15, boxLabel:'Link related hits together',  checked:true, style: {fontSize: '100%'}},
                {xtype:'displayfield', value: 'BLAST returns separate alignments for each query, and these separate alignments can further be ordered into sets offering consistent non-overlapping query and subject coverage.  The sequence viewer offers the ability to evaluate the original BLAST hits on-the-fly and link together alignments that meet a strict definition of non-overlapping query and subject coverage.',
                     height: 65}
            ],
            text: [
                {xtype:'displayfield', value: 'Please paste your alignment in ASN text or FASTA alignment (MUSCLE) format then press Upload',
                     width:'95%',  style:{fontSize: '122%'} },
                {xtype:'textarea', hideLabel:true, emptyText:'Please paste your text here', name: 'data', width:'99%', height:135,
                     validator: manageButt}
            ],
            url: [
                {xtype:'displayfield', value: 'Please specify the WEB URL to download the input file then press Upload',
                    width:'95%',  style:{fontSize: '122%'} },
                {xtype:'textfield', hideLabel:true, emptyText:'Please enter URL', name: 'dataURL', width:'99%', validator: manageButt}
            ],
            file: (helpTxt)
                ? [{xtype:'displayfield', value: helpTxt,
                    width:'95%',  style: {fontSize: '122%', color: 'red'}}]
                : [{xtype:'displayfield', value: 'Please specify or drop an input file then press Upload',
                     width:'95%',  style: {fontSize: '122%'}},
                   {xtype:'panel', layout: 'form',  border: false, bodyStyle: {background: 'inherit'},
                        items: [
                            {xtype: 'filefield',  itemId: 'datafile', fieldLabel: 'File to upload', listeners: {change: updateDropZone}},
                            {xtype: 'combo', itemId: 'file_format', triggerAction: 'all', width:120, name:'file_format', fieldLabel: 'File format', mode:'local',
                                store:[[ff[0],ff[0]], ['align', ff[1]], [ff[2], ff[2]], [ff[3], ff[3]]],
                                allowBlank: false, editable: false, value: ff[0]}
                        ]
                   },
                   {xtype: 'fieldset', title: 'Drag and drop file here', id: 'msa_dropzone', height: 60, labelWidth: 1, width: '100%',
                        items: [{xtype: 'displayfield', id: 'dz_datafile', value: ''}]}
                ]
        };
        var panel = this.down('#loaddatapanel');
        var dp = panel.down('#diff_part');
        if (dp) panel.remove(dp);
        panel.insert(0, new Ext.form.Panel({items: diff_parts[type], itemId: 'diff_part', border: false, bodyStyle: {background: 'inherit'}}));
        panel.setTitle(title);
        panel.updateLayout();

        if (!fileUploadDisabled && type.indexOf('file') >= 0) {   
            var ffld = uPanel.down('#datafile');
            var dzone = document.getElementById('msa_dropzone');
            dzone.ondragover = function(){ return false; };
            dzone.ondragleave = function(){ return false; };
            dzone.ondrop = function(e) {
                e.preventDefault();
                ffld.reset();
                processFName(ffld, e.dataTransfer.files[0]);
                uPanel.uploadButt.enable();
                uPanel.app.pingClick(MultiAlignView.area.uploadPanel + 'DnD');
                return false;
            };
        }
    }
});


Ext.apply(MultiAlignView.App.prototype, {

    showLinkURLDlg: function (logarea, e) {
        var makeTinyURL = (!e || !e.ctrlKey) ? NCBIGBUtils.makeTinyURL : function(lu, callback) { callback('skipTinyURL'); }
        if (logarea) this.pingClick(logarea);
        this.getLinkToThisPageURL(function (linkUrl) {
            this.resizeIFrame(450);
            var msaParams = linkUrl.substr(linkUrl.indexOf('?') + 1);
            if (msaParams.indexOf('report=graph') == 0) msaParams = 'id=' + this.GI + msaParams.substr(msaParams.indexOf('&'));
            var templates = {
                iframe: '<iframe id="iframe_@msa_id@" width="' + this.m_Align.m_View.getWidth() + '" src="' + MultiAlignView.base_url.replace(/http:/, 'https:')
                      + 'embedded_iframe.html?iframe=iframe_@msa_id@&' + msaParams + '&appname=ncbi_msav_demo" onload="'
                      + 'if(!window._MSAiFrame){_MSAiFrame=true;window.addEventListener(\'message\','
                      + 'function(e){if(e.origin==\'https://' + document.domain + '\' && !isNaN(e.data.h))'
                      + 'document.getElementById(e.data.f).height=parseInt(e.data.h);});}">\n</iframe>',
                div: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">\n'
                      + '<html>\n<head>\n<title>Embedded MultiAlignment Viewer with parameters</title>\n'
                      + '<script type="text/javascript" src="https://www.ncbi.nlm.nih.gov/projects/msaviewer/js/multialign.js"></script>'
                      + '</head>\n<body>'
                      + '<div id="msaviewer_@msa_id@" class="MultiAlignViewerApp" data-autoload>\n<a href="?embedded=true&' + msaParams + '&appname=ncbi_msav_demo"></a>\n</div>\n</body>\n</html>'};


            var showEmbedCode = function (tname) {
                var uname = linkDlg.down('#tinyURL').getValue().toLowerCase();
                var parts = uname.split('/');
                if (parts.length > 1) uname = parts.pop().trim();
                else uname = 'NCBI';
                linkDlg.down('#embedCode').setValue(templates[tname].replace(/@msa_id@/g, uname));
            }
            var warnMsg = {title: 'Warning(s)', icon: Ext.Msg.WARNING, buttons: Ext.Msg.OK,
                msg: !this.m_Key ? '' : 'This page contains a link to the user loaded data which is kept<br>' + 
                     'inside a temporary storage and will not be available in approximately 1-2 months.<br>'};

            var app = this;
            var linkDlg = new Ext.Window({
                app: this,
                layout: 'vbox',
                modal: true,
                title: 'Link To This View',
                width: 700,
                height: 450,
                constrain: true,
                cls: 'MultiAlignViewerApp',
                listeners: {
                    'beforeshow': function (qt) {
                        makeTinyURL(linkUrl, function (res) {
                            linkDlg.down('#tinyURL').setValue(res);
                            showEmbedCode('iframe');
                        });
                    }
                },
                resizable: true,
                closeAction: 'destroy',
                plain: true,
                bodyStyle: 'padding:4px 4px 4px 4px;',
                border: false,
                labelAlign: 'right',
                items: [
                    { xtype: 'textarea', height: 115, allowBlank: true, width: '100%', flex:1, value: linkUrl },
                    { xtype: 'textfield', itemId: 'tinyURL', allowBlank: true, width: '100%', emptyText: 'Loading...', value: '' },
                    { xtype: 'fieldset',  width: "100%", flex:2,
                      autoHeight: true,
                      title: 'Embedding code',
                      layout: 'vbox', // 'form',
                      items: [
                         { xtype: 'radiogroup', width: '100%',
                            items: [
                              { boxLabel: "Embed&nbsp;code&nbsp;for&nbsp;IFRAME", name:'rb-embed', checked: true },
                              { boxLabel: "Whole&nbsp;page&nbsp;example", name:'rb-embed',
                                  listeners: {
                                      change: function(fld, newval) { showEmbedCode(!newval ? 'iframe' : 'div'); }
                                  }}
                            ]},
                        { xtype: 'textarea', itemId: 'embedCode', allowBlank: true, flex:1, width: '100%', emptyText: 'Loading...', value: '' }
                    ]}
                ],
                buttons: [!warnMsg.msg ? '' : { itemId: 'warn', xtype: 'tbtext', minWidth: 30, height: 19, text: '', qtip: 'Tooltip', tooltip: 'Warning(s)',
                            style: 'background:url(' + MultiAlignView.ExtIconLoading.slice(5, -18) + 'shared/warning.gif) no-repeat 6px 2px;',
                            handler: function () { Ext.Msg.show(warnMsg); }},
                        '->', { text: 'Close', handler: function () { linkDlg.close(); app.resizeIFrame(); } }]
            });
            linkDlg.show();
            if (warnMsg.msg) {
                var w = linkDlg.down('#warn');
                w.tooltip = Ext.create('Ext.tip.ToolTip', {target: w.id, title: 'Warning(s)'});
                w.tooltip.setHtml(warnMsg.msg);
            }

        });
    },

    //////////////////////////////////////////////////////////////////////////
    // getLinkToThisPageURL:
    getLinkToThisPageURL: function (callback, mode) {
        var the_link = '';
        var params = [];
        if ((this.m_Portal || mode == 'portal') && mode != 'full') {
            var db = this.isProtein() ? 'protein' : 'nuccore';
            the_link = MultiAlignView.webNCBI + db + '/' + info.gi;
            params.push('report=graph');
        } else {
            the_link = MultiAlignView.base_url;
            if (this.GI) params.push('id=' + this.GI);
        }
        params.push('anchor=' + (this.m_Anchor || '-1'));
        var keys = [
            ["m_DataSource",    "datasource"],
            ["m_Coloring",      "coloring"],
//            ["m_Anchor",        "master",    "lcl|consensus"],
//            ["m_ShowConsensus", "consensus"],
            ["m_ShowIdentical", "identical", false],
            ['m_sort',          'sort'],
            ["m_Key",           "key"],
            ["m_TrackConfig",   "track_config"]
        ];
        for (var i = 0; i < keys.length; i++) {
            var keyentry = keys[i];
            if (this.hasOwnProperty(keyentry[0]) && this[keyentry[0]] !== null && this[keyentry[0]] !== "") {
                // don't write default value, if any
                if (keyentry[2] != undefined && keyentry[2] === this[keyentry[0]]) continue;
                // Special case for consensus as master row
//                if (keyentry[0] == "m_Anchor" && this.isConsensus(this.m_Anchor)) continue;
//                if (keyentry[1] == 'consensus' && this[keyentry[0]] && params.find(function(p){return !p.indexOf('master');})) continue;
                params.push(keyentry[1] + '=' + this[keyentry[0]]);
            }
        }
        
        var tracks = '';
        if (this.m_Tracks) tracks = this.m_Tracks;
        if (this.m_UploadedTracks.length > 0) {
            tracks += this.m_UploadedTracks.join('');
        }
        if (tracks) params.push("tracks=" + tracks);

        if (this.m_Align.m_FromSeq != this.m_Align.m_AlignStart ||
            this.m_Align.m_LenSeq  != this.m_Align.m_AlignLen)
        {
            params.push("from=" + (this.m_Align.m_FromSeq + 1));
            params.push("to="   + (this.m_Align.m_FromSeq + this.m_Align.m_LenSeq));
        }
        if (this.m_Align.m_Expand.length > 0) {
            params.push("expand=" + this.m_Align.m_Expand.join(','));
        }
        if (this.m_Align.m_HiddenSet.size  > 0) {
            params.push("hidden=" + Array.from(this.m_Align.m_HiddenSet).join(','));
        }
        var columns = this.m_Align.getColumns();
        if (columns != this.m_Align.getColumns(true)) params.push('columns=' + columns);
        if (params.length > 0) the_link += (the_link.indexOf('?') == -1 ? '?' : '&') + params.join('&');
        callback.call(this, the_link);
    },

    //////////////////////////////////////////////////////////////////////////
    // showFeedbackDlg:
    showFeedbackDlg: function (fbText, fbURL) {
        var app = this;
        var fbCallback = function (the_link_url) {
            app.resizeIFrame(400);
            var feedbackType = ['Suggestion', 'Bug Report', 'Other', 'Initial upload error'];
            var fbType = (fbText) ? 3 : 0;
            if (!fbType) feedbackType.pop();
            var feedbackDlg = new Ext.Window({
                layout: 'fit', modal: true,
                title: 'NCBI Multiple Alignment Viewer feedback',
                width: 600, height: 360,
                minWidth: 400, minHeight: 260,
                constrain: true, resizable: true,
                cls: 'MultiAlignViewerApp',
                items: [{
                    xtype: 'form',
                    bodyStyle: 'padding:5px;',
                    labelWidth: 140,
                    frame: true,
                    labelAlign: 'right',
                    items: [
                        { xtype: 'combo', triggerAction: 'all', fieldLabel: 'Feedback Type', mode: 'local', name: 'feedback-type',
                          store: feedbackType, allowBlank: false, editable: false, value: feedbackType[fbType], disabled: (fbType > 0) },
                        { xtype: 'textfield', fieldLabel: 'EMail (Optional)', vtype: 'email', allowBlank: true, anchor: '100%', name: 'feedback-email' },
                        { xtype: 'textarea', fieldLabel: '*Feedback', allowBlank: false, anchor: '100% -50', name: 'feedback-text', value: fbText }
                      ]
                }],
                buttons: [
                  { text: 'Send', handler: function () {
                      var form = feedbackDlg.items.items[0].getForm();
                      if (form.isValid()) {
                          var cfg_data = form.getValues();
                          cfg_data['feedback-browser'] = Ext.browser.name + ' ver. ' + Ext.browser.version.version;
                          cfg_data['feedback-os'] = Ext.os.name;
                          NCBIGBUtils.makeTinyURL(the_link_url, function (res) {
                              cfg_data['feedback-url'] = the_link_url + '\n' + (res || '');
                              app.AjaxRequest({ url: app.m_CGIs.Feedback, data: cfg_data, context: feedbackDlg,
                                  success: function (data) {
                                      this.close();
                                      Ext.MessageBox.show({ title: 'Feedback', msg: 'Thank you! We appreciate your feedback.',
                                          buttons: Ext.MessageBox.OK, icon: Ext.MessageBox.INFO
                                      });
                                  },
                                  error: function (data, txt, res) {
                                      console.log('Failed to send feedback: ' + txt);
                                  }
                              });
                          });
                      }
                  }
                  },
                  { text: 'Cancel', handler: function () { feedbackDlg.close(); } }
               ]
            });
            feedbackDlg.on('close', function () { app.resizeIFrame(); });

            if (app.m_iFrame)
                Ext.Function.defer(feedbackDlg.show, 500, feedbackDlg);
            else
                feedbackDlg.show();
        }
        if (fbText) fbCallback(fbURL);
        else this.getLinkToThisPageURL(fbCallback);
    },


    showColumnsDialog: function() {
        var view = this.m_Align;

        var btnHandler = function(btn) {
            if (btn.text != 'Cancel') {
                var sel_str = '';
                view.pingClick(MultiAlignView.area.toolbar.columns[btn.text]);
                if (btn.text == 'Apply') {
                    var not_sel_ids = [],
                        sel = columnsDialog.msaColsGrid.getSelection();
                    columnsDialog.msaColsGrid.getStore().getData().items.forEach(function(c) {
                        sel_str += c.id + ':' + (sel.find(function(s) { return s.id == c.id; }) ? c.data.width : '0') + ',';
                    });
                }
                view.m_App.setColumns(sel_str.slice(0, -1), true);
            }
            columnsDialog.close();
        }

        var columnsDialog = new Ext.Window({
            title: 'Columns selection',
            modal: true,
            constrain: true,
            width: 'auto',
            height: 300,
            layout: 'fit',
            cls: 'MultiAlignViewerApp',
            buttons: [                
                { text: 'Apply', handler: btnHandler },
                { text: 'Default', handler: btnHandler },
                { text: 'Cancel', handler: btnHandler }
            ]
        });

        if (typeof MSAColRowsModel === 'undefined')
            Ext.define('MSAColRowsModel', { extend: 'Ext.data.Model', idProperty: 'ID',
                fields: [{name: 'name'}, {name: 'width'}, {name: 'ID'}]
            });
        var columnsData = [],
            alnRows = view.m_App.m_AlignRows || [];

        view.m_ColumnTable.forEach(function (c) {
            var cfg = c.cfg;
            if (cfg.name && (!cfg.rqv || alnRows.find(function(r){ return r[cfg.rqv]; }))) {
                var name = cfg.tooltip;
                columnsData.push([name == cfg.name ? name : name + ' (' + cfg.name + ')', cfg.width, c.id]);
            }
        });
        var cStore = Ext.create('Ext.data.ChainedStore', {
                source: Ext.create('Ext.data.ArrayStore', { model: 'MSAColRowsModel', data: columnsData })
        });

        columnsDialog.msaColsGrid = Ext.create('Ext.grid.Panel', {
            store: cStore,
            plugins: {cellediting: { clicksToEdit: 1 }},
            columns: [
                {header: "Column Name", width: 320, sortable: false, dataIndex: 'name', flex:true},
                {header: 'Width (pixels)', width: 90, sortable: false, dataIndex: 'width', hidden: true, editor: {
                    xtype: 'numberfield',
                    selectOnFocus: false,
                    allowBlank: false,
                    
                    minValue: 0,
                    maxValue: 400
                }}],
            enableColumnHide: false,
            selModel: { type: 'checkboxmodel', checkOnly: true }
        });

        var selModel = columnsDialog.msaColsGrid.getSelectionModel();
        selModel.deselectAll();

        view.m_ColumnTable.forEach(function(c) {
            if (c.cfg.name && c.order && c.cfg.width) selModel.select(cStore.getById(c.id), true);
        });

        columnsDialog.add(columnsDialog.msaColsGrid);
        columnsDialog.show();
    },

    showRowDialog: function() {
        if (this.m_AlignRows == undefined) return;
        var view = this.m_Align,
            anchor = this.m_Anchor,
            alnRows = this.m_AlignRows,
            anchorRow = alnRows.find(function(r) { return r.id == anchor; }),
            fields = [{name: 'Name', prop: 'title'}],
            columns = [{text: "Name", width: 220, sortable: true, dataIndex: 'Name'/*, flex:true*/}],
            dCols = view.defaultColumnTable;

         for (var id in dCols) {
            var c = dCols[id];
            if (!c.rqv) continue;
            fields.push({name: c.name, prop: c.rqv});
            columns.push({text: c.name, sortable: true, dataIndex: c.name, width: c.width, hidden: alnRows.findIndex(function(r) { return r[c.rqv]; }) == -1});
        }

        fields.push({name: 'ID', prop: 'id'});
        if (typeof MSARowsModel == 'undefined') {
            Ext.define('MSARowsModel', { extend: 'Ext.data.Model', idProperty: 'ID', fields: fields});
        }
        var MSARowsData = [];

        alnRows.forEach(function(r) {
            if (r.acc != 'consensus' && r.id != anchor)
                MSARowsData.push(fields.map(function(f) { return r[f.prop]; }));
        });

        var cStore = Ext.create('Ext.data.ChainedStore', {
            source: Ext.create('Ext.data.ArrayStore', { model: 'MSARowsModel', data: MSARowsData })
        });

        var btnHandler = function(btn, event) {
            if (btn.text == 'Apply') {
                var not_sel_ids = [];
                var sel = rowDialog.msaRowsGrid.getSelectionModel().getSelected().items;
                alnRows.forEach(function(r) {
                    if (!sel.find(function(s) { return s.id == r.id; })) not_sel_ids.push(r.id);
                });
                view.setHidden(not_sel_ids);
                view.pingClick(MultiAlignView.area.toolbar.rows.Apply);
            } else {
                if (btn.text != 'Cancel') {
                    rowDialog.msaRowsGrid.getColumns().forEach(function(c) {
                        if (!c.text) return;
                        view.m_ColumnTable.find(function(ct) {
                            if (ct.cfg.name == c.text) { ct.cfg.width = c.width; return true; }});
                    });
                    view.initColumns();
                    view.reload(true);
                }
            }
            rowDialog.close();
        }

        var rowDialog = new Ext.Window({
            title: 'Rows selection',
            modal: true,
            constrain: true,
            width: 'auto',//dialog_width,
            height: 400,
            layout: 'fit',
            cls: 'MultiAlignViewerApp',
            buttons: [
                { text: 'Apply', handler: btnHandler },
                { text: 'Apply Column Widths', handler: btnHandler, hidden: this.m_hiddenOptions.indexOf('column_width') == -1},
                { text: 'Cancel', handler: btnHandler }
            ]
        });

        rowDialog.msaRowsGrid = Ext.create('Ext.grid.Panel', {
            title: anchorRow ? 'Anchor row ' + anchorRow.acc + ' cannot be hidden' : false,
            store: cStore,
            columns: columns,
            columnLines: true,
            selModel: { type: 'checkboxmodel', checkOnly: true },
            frame: true
        });

        var selModel = rowDialog.msaRowsGrid.getSelectionModel();
        selModel.selectAll();
        view.m_HiddenSet.forEach(function(id) { selModel.deselect(cStore.getById(id), true); });
        rowDialog.add(rowDialog.msaRowsGrid);
        rowDialog.show();
    },


    showUploadDialog: function(callback, scope) {
        var uploadDialog = new Ext.Window({
            title: 'Upload Data',
            modal: true,
            constrain: true,
            width:750,
            height:550,
            layout: 'fit',
            cls: 'MultiAlignViewerApp',
            buttons: [{
                text: 'Close',
                handler: function() { uploadDialog.close()}
            }]
        });
        var oldState = {};
        ['m_Key', 'GI', 'm_Coloring', 'm_ConsensusId', 'm_Anchor', 'm_ShowConsensus'].forEach(function(atr){
            oldState[atr] = this[atr];
            delete this[atr];// = null;
        }, this); 
        uploadDialog.add(new MultiAlignView.UploadPanel({app: this}));
        uploadDialog.on({ 'close': function(p) {
            if (this.m_Uploaded) {
                if (!this.m_Embedded && MultiAlignView.standalone && this.m_UrlParams) {
                    window.history.pushState(null, "", "?" + this.m_UrlParams);
                    delete this.m_UrlParams;
                }

                if (callback) callback.call(scope);
            } else {
                Ext.apply(this, oldState);
                if (callback && !this.GI && !this.m_Key) callback.call(scope);
            }
            delete this.m_Uploaded;                
        }, scope: this });
        uploadDialog.show();
    },


    downloadImgFile: function() {
        var formPanel,
            view = this.m_Align,
            params = { view:'msa', client:'assmviewer', width: this.m_BrowWidth, columns: view.getColumns(), shown: 65535 };
        view.addURLParams(params);

        var reportStatus = function(text, icon) {
            var st = win.down('#status');
            if (typeof text == 'string') st.setText(text || '&nbsp;');
            st.setStyle('background', icon || '');
            st.setStyle('padding', (st.el.getStyle('background-image') != 'none' ? '0 22px' : '0 3px'));;
        }

        var btnHandler = function(btn, event) {
            if (!formPanel.fileURL) {
                this.pingClick(MultiAlignView.area.toolbar.download.pdfsvg);
                var ret = this.checkRange(formPanel.down('#range').getValue());
                if (typeof ret == 'string') reportStatus(ret);
                else 
                    createImageFile(ret, btn.itemId, params);
                return;
            }
            switch (btn.itemId) {
                case 'save': this.saveFile(formPanel.fileURL); break;
                case 'view': window.open(formPanel.fileURL + '&inline=true'); break;
            }
        }

        var createImageFile = function(range, nextAction, params) {
            Ext.apply(params, { from: range[0], len: range[1] - range[0] + 1,
                target: this.m_PDFDownloadType ? 'pdf' : (this.m_hiddenOptions.indexOf('svgz') >= 0 ? 'svgz' : 'svg'),
                print_title: formPanel.down('#title').checked,
                simplified: formPanel.down('#simplified').checked
            });
            
            var processResponse = function(data, text, res) {
                if (formPanel.destroyed) return;
    
                var from_cgi = MultiAlignView.decode(data);
                if (from_cgi.job_status) {
                    if (from_cgi.job_status == 'failed' || from_cgi.job_status == 'canceled') {
                        Ext.MessageBox('Error', from_cgi.error_message);
                        reportStatus(from_cgi.error_message);
                    } else {
                        if (from_cgi.progress_message)
                            reportStatus(Ext.decode(from_cgi.progress_message.replace(/\&quot;/gi, "\"")));
                        Ext.defer(MultiAlignView.App.simpleAjaxRequest, 500, this, [{
                            url: this.m_CGIs.Alignment + '?job_key=' + from_cgi.job_id, context: this,
                            success: processResponse,
                            error: processResponse }]);
                    }
                } else {
                    var fURL = from_cgi.file_url;
                    if (!fURL) {
                        reportStatus('Request failed');
                        return;
                    }
                    // If the file_url begins with ? it contains only parameters for ncfetch, so prepend ncfetch URL
                    if (fURL.charAt(0) == '?') fURL = this.m_CGIs.NetCache + fURL;
    
                    formPanel.fileURL = fURL += '&filename=' + this.m_DataInfo.acc_type + '_alignment[' + (range[0] + 1) + '..' 
                        + (range[1] + 1) + ']' + '.' + params.target;
    
                    reportStatus(Ext.util.Format.fileSize(from_cgi.file_size, .98) + ' ' + params.target + ' file created');
    
                    if (nextAction == 'save') this.saveFile(formPanel.fileURL);
                    else window.open(formPanel.fileURL + '&inline=true');
                }
            }
            this.AjaxRequest({url: this.m_CGIs.Alignment, context: this, data: params, success: processResponse, error: processResponse });
            reportStatus('Creating File (' + params.target + ')', MultiAlignView.ExtIconLoading + ' no-repeat');
        }.bind(this);

        var win = new Ext.Window({ title: 'Download Image', cls: 'MultiAlignViewerApp',
            constrain: true, modal: true, plain: true, layout:'fit',
            minWidth: 500, width: 500, height: 300,
            bbar: [{ xtype: 'tbtext', itemId: 'status', html: 'Ready' }]
        });

        if (this.m_PDFDownloadType === undefined) this.m_PDFDownloadType = true;

        var fpHandler = function() {
            formPanel.down('#save').show();
            delete formPanel.fileURL;
            reportStatus('');
        }

        var viewFrom = this.posToLocal(view.posToSeq(0));
        formPanel = new Ext.FormPanel({
            labelWidth: 1, // label settings here cascade unless overridden
            frame: true,
            bodyStyle: 'padding:5px 5px 0',
            items: [
            { xtype:'fieldset', title: 'Enter Sequence Range', autoHeight: true, defaultType: 'textfield',
                items :[
                    { xtype: 'label', html: 'Possible range formats include 10K-20K, 10:20, 20000-30000, 5 to 515, 1...246<br><br>' },
                    { itemId: 'range', width: '100%', value: viewFrom + ':' + (viewFrom + view.m_LenSeq - 1), listeners: { change: fpHandler }}
                ]},
            { xtype:'checkbox', itemId: 'title', checked: true, boxLabel: 'Include Title', hidden: true,
                listeners: { change: fpHandler }},
            { xtype:'checkbox', itemId: 'simplified', checked: (this.m_PDFcomp) ? this.m_PDFcomp : false, boxLabel: 'Simplified color shading (allows greater compatibility with image editors)',
                listeners: { change: fpHandler }},
            { xtype: 'displayfield', value: 'File type: (PDF and SVG contain vector graphics for high quality images)',
                 style: {color:'grey', "text-align": 'left', "margin-top":'10px', "margin-left":'6px'}},
            { xtype: 'radiogroup', columns: 1, vertical: true,
              listeners: { scope: this,
                  change: function (cb, nv, ov) {
                      this.m_PDFDownloadType = nv.isPDF;
                      formPanel.down('#view')[nv.isPDF ? 'show' : 'hide']();
                      delete formPanel.fileURL;
                      reportStatus('');
               }},
               items: [
                    { boxLabel: 'PDF', name: 'isPDF', inputValue: true, checked: this.m_PDFDownloadType },
                    { boxLabel: 'SVG', name: 'isPDF', inputValue: false, checked: !this.m_PDFDownloadType }
                ]}
            ],
            buttons: [{
                text: 'Preview', itemId: 'view', scope: this, disabled: false, hidden: !this.m_PDFDownloadType, handler: btnHandler },{
                text: 'Download', itemId: 'save', scope: this, disabled: false, handler: btnHandler },{
                text: 'Cancel', handler: function() { win.close(); }
            }]
        });
        win.add(formPanel);
        win.show();
    }

});

}
