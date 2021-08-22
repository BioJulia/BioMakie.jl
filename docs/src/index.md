# BioMakie.jl Documentation

```@meta
CurrentModule = BioMakie
```
```@raw html
<title>PDBe Mol* Helper Functions</title>
    
    <!-- Required for IE11 -->
    <script src="https://cdn.jsdelivr.net/npm/babel-polyfill/dist/polyfill.min.js"></script>
    <!-- Web component polyfill (only loads what it needs) -->
    <script src="https://cdn.jsdelivr.net/npm/@webcomponents/webcomponentsjs/webcomponents-lite.js" charset="utf-8"></script>
    <!-- Required to polyfill modern browsers as code is ES5 for IE... -->
    <script src="https://cdn.jsdelivr.net/npm/@webcomponents/webcomponentsjs/custom-elements-es5-adapter.js" charset="utf-8"></script>

    <link rel="stylesheet" type="text/css" href="https://www.ebi.ac.uk/pdbe/pdb-component-library/css/pdbe-molstar-1.1.0.css">
    <script type="text/javascript" src="https://www.ebi.ac.uk/pdbe/pdb-component-library/js/pdbe-molstar-component-1.1.0.js"></script>
    <style>
        #myViewer{
          float:left;
          width:670px;
          height: 400px;
          position:relative;
        }
    </style><meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1.0"/><title>Home · BioMakie.jl</title><script data-outdated-warner src="assets/warner.js"></script><link rel="canonical" href="https://kool7d.github.io/BioMakie.jl/stable/index.html"/><link href="https://cdnjs.cloudflare.com/ajax/libs/lato-font/3.0.0/css/lato-font.min.css" rel="stylesheet" type="text/css"/><link href="https://cdnjs.cloudflare.com/ajax/libs/juliamono/0.039/juliamono-regular.css" rel="stylesheet" type="text/css"/><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/fontawesome.min.css" rel="stylesheet" type="text/css"/><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/solid.min.css" rel="stylesheet" type="text/css"/><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/brands.min.css" rel="stylesheet" type="text/css"/><link href="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.13.11/katex.min.css" rel="stylesheet" type="text/css"/><script>documenterBaseURL="."</script><script src="https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js" data-main="assets/documenter.js"></script><script src="siteinfo.js"></script><script src="../versions.js"></script><link class="docs-theme-link" rel="stylesheet" type="text/css" href="assets/themes/documenter-dark.css" data-theme-name="documenter-dark" data-theme-primary-dark/><link class="docs-theme-link" rel="stylesheet" type="text/css" href="assets/themes/documenter-light.css" data-theme-name="documenter-light" data-theme-primary/><script src="assets/themeswap.js"></script></head><body><div id="documenter"><nav class="docs-sidebar"><div class="docs-package-name"><span class="docs-autofit"><a href="index.html">BioMakie.jl</a></span></div><form class="docs-search" action="search.html"><input class="docs-search-query" id="documenter-search-query" name="q" type="text" placeholder="Search docs"/></form><ul class="docs-menu"><li class="is-active"><a class="tocitem" href="index.html">Home</a></li><li><a class="tocitem" href="API.html">API</a></li></ul><div class="docs-version-selector field has-addons"><div class="control"><span class="docs-label button is-static is-size-7">Version</span></div><div class="docs-selector control is-expanded"><div class="select is-fullwidth is-size-7"><select id="documenter-version-selector"></select></div></div></div></nav><div class="docs-main"><header class="docs-navbar"><nav class="breadcrumb"><ul class="is-hidden-mobile"><li class="is-active"><a href="index.html">Home</a></li></ul><ul class="is-hidden-tablet"><li class="is-active"><a href="index.html">Home</a></li></ul></nav><div class="docs-right"><a class="docs-edit-link" href="https://github.com/kool7d/BioMakie.jl/blob/master/docs/src/index.md" title="Edit on GitHub"><span class="docs-icon fab"></span><span class="docs-label is-hidden-touch">Edit on GitHub</span></a><a class="docs-settings-button fas fa-cog" id="documenter-settings-button" href="#" title="Settings"></a><a class="docs-sidebar-button fa fa-bars is-hidden-desktop" id="documenter-sidebar-button" href="#"></a></div></header><article class="content" id="documenter-page"><h1 id="BioMakie.jl-Documentation"><a class="docs-heading-anchor" href="#BioMakie.jl-Documentation">BioMakie.jl Documentation</a><a id="BioMakie.jl-Documentation-1"></a><a class="docs-heading-anchor-permalink" href="#BioMakie.jl-Documentation" title="Permalink"></a></h1><link rel="stylesheet" type="text/css" href="https://molstar.org/viewer/molstar.css" />
<h4>PDBe Mol* Web-component Demo</h4>
<!-- Molstar container -->
<div id="myViewer">
    <pdbe-molstar id="pdbeMolstarComponent" molecule-id="2nnu" hide-controls="true"></pdbe-molstar>
</div>
<!-- Required for IE11 -->
<script src="https://cdn.jsdelivr.net/npm/babel-polyfill/dist/polyfill.min.js"></script>
<!-- Web component polyfill (only loads what it needs) -->
<script src="https://cdn.jsdelivr.net/npm/@webcomponents/webcomponentsjs/webcomponents-lite.js" charset="utf-8"></script>
<!-- Required to polyfill modern browsers as code is ES5 for IE... -->
<script src="https://cdn.jsdelivr.net/npm/@webcomponents/webcomponentsjs/custom-elements-es5-adapter.js" charset="utf-8"></script>

<!-- CSS -->
<link rel="stylesheet" type="text/css" href="https://www.ebi.ac.uk/pdbe/pdb-component-library/css/pdbe-molstar-1.1.0.css">

<!-- For Light Theme include this css file instead of above -->
<!--<link rel="stylesheet" type="text/css" href="https://www.ebi.ac.uk/pdbe/pdb-component-library/css/pdbe-molstar-light-1.1.0.css">-->
<!--
Tip: Set background color to white for light theme
-->

<!-- JS -->
<script type="text/javascript" src="https://www.ebi.ac.uk/pdbe/pdb-component-library/js/pdbe-molstar-component-1.1.0.js"></script>
```
```@example 2
using JSServe
using WGLMakie
Page(exportable=true, offline=true)

using Markdown

struct GridCard
    elements::Any
end

GridCard(elements...) = GridCard(elements)

function JSServe.jsrender(card::GridCard)
    return DOM.div(JSServe.TailwindCSS, card.elements..., class="rounded-lg p-2 m-2 shadow-lg grid auto-cols-max grid-cols-2 gap-4")
end

App() do session::Session
    # We can now use this wherever we want:
    fig = Figure()
    lscene = LScene(fig[1, 1])

    card = GridCard(
        Slider(1:100),
        DOM.h1("hello"),
        DOM.img(src="https://julialang.org/assets/infra/logo.svg"),
        fig
    )
    # Markdown creates a DOM as well, and you can interpolate
    # arbitrary jsrender'able elements in there:
    return md"""

    # Wow, Markdown works as well?

    $(card)

    """
end
```
```@example 4
using JSServe
using JSServe: onjs, evaljs, on_document_load
using WGLMakie
WGLMakie.activate!()

app = App() do session::Session
    s1 = Slider(1:100)
    slider_val = DOM.p(s1[]) # initialize with current value

    fig, ax, splot = WGLMakie.scatter(1:4)

    # With on_document_load one can run JS after everything got loaded.
    # This is an alternative to `evaljs`, which we can't use here,
    # since it gets run asap, which means the plots won't be found yet.

    on_document_load(session, js"""
        const plots = $(splot)
        const scatter_plot = plots[0]
        // open the console with ctr+shift+i, to inspect the values
        // tip - you can right click on the log and store the actual variable as a global, and directly interact with it to change the plot.
        console.log(scatter_plot)
        console.log(scatter_plot.material.uniforms)
        console.log(scatter_plot.geometry.attributes)
    """)

    # with the above, we can find out that the positions are stored in `offset`
    # (*sigh*, this is because threejs special cases `position` attributes so it can't be used)
    # Now, lets go and change them when using the slider :)
    onjs(session, s1.value, js"""function on_update(new_value) {
        const plots = $(splot)
        const scatter_plot = plots[0]

        // change first point x + y value
        scatter_plot.geometry.attributes.offset.array[0] = (new_value/100) * 4
        scatter_plot.geometry.attributes.offset.array[1] = (new_value/100) * 4
        // this always needs to be set of geometry attributes after an update
        scatter_plot.geometry.attributes.offset.needsUpdate = true
    }
    """)
    # and for got measures, add a slider to change the color:
    color_slider = Slider(LinRange(0, 1, 100))
    onjs(session, color_slider.value, js"""function on_update(hue) {
        const plot = $(splot)[0]
        const color = new THREE.Color()
        color.setHSL(hue, 1.0, 0.5)
        plot.material.uniforms.color.value.x = color.r
        plot.material.uniforms.color.value.y = color.g
        plot.material.uniforms.color.value.z = color.b
    }""")

    markersize = Slider(1:100)
    onjs(session, markersize.value, js"""function on_update(size) {
        const plot = $(splot)[0]
        plot.material.uniforms.markersize.value.x = size
        plot.material.uniforms.markersize.value.y = size
    }""")
    return DOM.div(s1, color_slider, markersize, fig)
end
```