export UniProtData,
    getuniprotdata,
    showuniprotdata

"""
    UniProtData::DataType

A struct containing all the information from a UniProt entry.

# General information
accession
id
protinfo
gene
gene_synonyms
secondary_accession
sequence
organism
datainfo

# Features
molecule_processing
domains_and_sites
structural
ptm
sequence_information
mutagenesis
variants
topology
other_features

# Comments
func
catalytic_activity
subunit
subcellular_location
interaction
tissue_specificity
polymorphism
allergen
web_resource
similarity
miscellaneous
other_comments

# Database references (EMBL, PDB, etc.)
dbrefs

"""
mutable struct UniProtData
    # General information
    accession::Union{String,Vector{String}}
    id::Union{String,Vector{String}}
    protinfo::OrderedDict{Symbol,Any}
    gene::Union{String,Vector{String}}
    gene_synonyms::Union{String,Vector{String}}
    secondary_accession::Union{String,Vector{String}}
    sequence::Union{String,Vector{String}}
    organism::OrderedDict{Symbol,Any}
    datainfo::OrderedDict{Symbol,Any}

    # Features
    molecule_processing
    domains_and_sites
    structural
    ptm
    sequence_information
    mutagenesis
    variants
    topology
    other_features

    # Comments
    func
    catalytic_activity
    subunit
    subcellular_location
    interaction
    tissue_specificity
    polymorphism
    allergen
    web_resource
    similarity
    miscellaneous
    other_comments

    # Database references (EMBL, PDB, etc.)
    dbrefs
end

"""
    getuniprotdata(jsonfile; include_refs = false)

Reads a UniProt JSON file and returns a UniProtData struct.

### Keyword  Arguments:
- include_refs::Bool = false    Whether to include allthe database references (EMBL, PDB, etc.) in the struct.
                                can be very large, so it is `false` by default.
"""
function getuniprotdata(jsonfile; include_refs = false)
    # General information
    accession = ""
    id = ""
    protinfo = OrderedDict[]
    gene = ""
    gene_synonyms = String[]
    secondary_accession = String[]
    sequence = ""
    organism = OrderedDict[]
    datainfo = OrderedDict[]

    # Features
    molecule_processing = OrderedDict[]
    domains_and_sites = OrderedDict[]
    structural = OrderedDict[]
    ptm = OrderedDict[]
    sequence_information = OrderedDict[]
    mutagenesis = OrderedDict[]
    variants = OrderedDict[]
    topology = OrderedDict[]
    other_features = OrderedDict[]

    # Comments
    func = []
    catalytic_activity = []
    subunit = []
    subcellular_location = []
    interaction = []
    tissue_specificity = []
    polymorphism = []
    allergen = []
    web_resource = []
    similarity = []
    miscellaneous = []
    other_comments = []
    dbrefs = []

    filestring = read(jsonfile,String)
    jsondata = JSON3.read(filestring)

    @trycatch accession = jsondata[:accession]
    @trycatch id = jsondata[:id]
    @trycatch datainfo = OrderedDict(jsondata[:info])
    @trycatch organism = OrderedDict(jsondata[:organism])
    @trycatch sequence = jsondata[:sequence][:sequence]
    @trycatch secondary_accession = jsondata[:secondaryAccession] |> collect
    @trycatch gene = jsondata[:gene][1][:name][:value]
    @trycatch gene_synonyms = jsondata[:gene][1][:name][:value]

    @trycatch protinfo = jsondata[:protein] |> Dict

    featuredicts = jsondata[:features]

    commentdicts = jsondata[:comments]

    if include_refs == true
        dbrefs = jsondata[:dbReferences]
        dbrefs = OrderedDict{Symbol,String}.(dbrefs)
    end

    for dict in commentdicts
        type = dict[:type]
        if type == "FUNCTION"
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                        JSON3.read(outdata, Dict)
                    else
                        outdata = dict[:text][1]
                        JSON3.read(outdata, Dict)
                    end
                    push!(func, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                            JSON3.read(outdata, Dict)
                        else
                            outdata = dict[:text][1][1]
                            JSON3.read(outdata, Dict)
                        end
                        push!(func, outdata)
                    catch
                        push!(func, dict[:text])
                    end
                end
            catch
                push!(func, dict)
            end
        elseif type == "CATALYTIC_ACTIVITY"
            @trycatch push!(catalytic_activity, dict[:reaction] |> OrderedDict)
        elseif type == "SUBUNIT"
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                    else
                        outdata = dict[:text][1]
                    end
                    push!(subunit, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                        else
                            outdata = dict[:text][1][1]
                        end
                        push!(subunit, outdata)
                    catch
                        push!(subunit, dict[:text])
                    end
                end
            catch
                push!(subunit, dict)
            end
        elseif type == "SUBCELLULAR_LOCATION"
            @trycatch push!(subcellular_location, dict[:locations])
        elseif type == "INTERACTION"
            @trycatch push!(interaction, dict[:interactions])
        elseif type == "TISSUE_SPECIFICITY"
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                    else
                        outdata = dict[:text][1]
                    end
                    push!(tissue_specificity, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                        else
                            outdata = dict[:text][1][1]
                        end
                        push!(tissue_specificity, outdata)
                    catch
                        push!(tissue_specificity, dict[:text])
                    end
                end
            catch
                push!(tissue_specificity, dict)
            end
        elseif type == "POLYMORPHISM"
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                    else
                        outdata = dict[:text][1]
                    end
                    push!(polymorphism, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                        else
                            outdata = dict[:text][1][1]
                        end
                        push!(polymorphism, outdata)
                    catch
                        push!(polymorphism, dict[:text])
                    end
                end
            catch
                push!(polymorphism, dict)
            end
        elseif type == "ALLERGEN"
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                    else
                        outdata = dict[:text][1]
                    end
                    push!(allergen, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                        else
                            outdata = dict[:text][1][1]
                        end
                        push!(allergen, outdata)
                    catch
                        push!(allergen, dict[:text])
                    end
                end
            catch
                push!(allergen, dict)
            end
        elseif type == "MISCELLANEOUS"
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                    else
                        outdata = dict[:text][1]
                    end
                    push!(miscellaneous, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                        else
                            outdata = dict[:text][1][1]
                        end
                        push!(miscellaneous, outdata)
                    catch
                        push!(miscellaneous, dict[:text])
                    end
                end
            catch
                push!(miscellaneous, dict)
            end
        elseif type == "WEBRESOURCE"
            @trycatch push!(web_resource, dict)
        elseif type == "SIMILARITY"
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                    else
                        outdata = dict[:text][1]
                    end
                    push!(similarity, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                        else
                            outdata = dict[:text][1][1]
                        end
                        push!(similarity, outdata)
                    catch
                        push!(similarity, dict[:text])
                    end
                end
            catch
                push!(similarity, dict)
            end
        else
            try
                try
                    if size(dict[:text]) > 1
                        outdata = dict[:text]
                    else
                        outdata = dict[:text][1]
                    end
                    push!(other_comments, outdata)
                catch
                    try
                        if size(dict[:text][1]) > 1
                            outdata = dict[:text][1]
                        else
                            outdata = dict[:text][1][1]
                        end
                        push!(other_comments, outdata)
                    catch
                        push!(other_comments, dict[:text])
                    end
                end
            catch
                push!(other_comments, dict)
            end
        end
    end

    for dict in featuredicts
        category = dict[:category]
        type = ""
        description = ""
        bgin = ""
        endd = ""
        @trycatch type = dict[:type]
        @trycatch description = dict[:description]
        @trycatch bgin = dict[:begin]
        @trycatch endd = dict[:end]
        evidences = OrderedDict[]

        @trycatch for i in 1:size(dict[:evidences],1)
            codei = dict[:evidences][i][:code]
            namei = dict[:evidences][i][:source][:name]
            idi = dict[:evidences][i][:source][:id]
            urli = dict[:evidences][i][:source][:url]
            push!(evidences,OrderedDict(:code => codei,
                                            :name => namei,
                                            :id => idi,
                                            :url => urli))
        end
        if category == "MOLECULE_PROCESSING"
            push!(molecule_processing, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))

        elseif category == "DOMAINS_AND_SITES"
            push!(domains_and_sites, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))
            
        elseif category == "STRUCTURAL"
            push!(structural, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))
            
        elseif category == "PTM"
            push!(ptm, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))
            
        elseif category == "SEQUENCE_INFORMATION"
            push!(sequence_information, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))
            
        elseif category == "MUTAGENESIS"
            push!(mutagenesis, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))

        elseif category == "VARIANTS"
            push!(variants, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))

        elseif category == "TOPOLOGY"
            push!(topology, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))

        else
            push!(other_features, OrderedDict(:type => type,
                                            :description => description,
                                            :begin => bgin,
                                            :end => endd,
                                            :evidences => evidences))
        end
    end

    return UniProtData(
        accession,
        id,
        protinfo,
        gene,
        gene_synonyms,
        secondary_accession,
        sequence,
        organism,
        info,
        molecule_processing,
        domains_and_sites,
        structural,
        ptm,
        sequence_information,
        mutagenesis,
        variants,
        topology,
        other_features,
        func,
        catalytic_activity,
        subunit,
        subcellular_location,
        interaction,
        tissue_specificity,
        polymorphism,
        allergen,
        web_resource,
        similarity,
        miscellaneous,
        other_comments,
        dbrefs
        )
end

"""
    showuniprotdata(pdata)

Prints some of the most important information from a UniProtData object.
"""
function showuniprotdata(pdata)
    ["Accession: $(pdata.accession)", 
    "ID: $(pdata.id)", 
    "Name: $(pdata.protinfo[:recommendedName][:fullName][:value])", 
    "EC Number: $(pdata.protinfo[:recommendedName][:ecNumber][1][:value])",
    "Alternative Name: $(pdata.protinfo[:alternativeName][1][:fullName][:value])",
    "Gene: $(pdata.gene)", 
    "Secondary accession: $(pdata.secondary_accession)"]
end
