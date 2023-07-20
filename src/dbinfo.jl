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
function json_to_dict_or_array(value)
    if value isa JSON3.Object
        dict = OrderedDict{Symbol,Any}()
        for (key, val) in value
            dict[key] = json_to_dict_or_array(val)  # Recursively convert nested objects or arrays
        end
        return dict
    elseif value isa JSON3.Array
        arr = []
        for item in value
            push!(arr, json_to_dict_or_array(item))  # Recursively convert nested objects or arrays
        end
        return arr
    else
        return value
    end
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
    dbrefs = OrderedDict[]

    filestring = read(jsonfile,String)
    jsondata = JSON3.read(filestring)

    @trycatch accession = jsondata[:accession]
    @trycatch id = jsondata[:id]
    @trycatch protinfo = jsondata[:protein] |> Dict
    @trycatch gene = jsondata[:gene][1][:name][:value]
    @trycatch gene_synonyms = jsondata[:gene][1][:name][:value]
    @trycatch secondary_accession = jsondata[:secondaryAccession] |> collect
    @trycatch sequence = jsondata[:sequence][:sequence]
    @trycatch organism = OrderedDict(jsondata[:organism])
    @trycatch datainfo = OrderedDict(jsondata[:info])
 
    featuredicts = jsondata[:features]
    commentdicts = jsondata[:comments]

    if include_refs == true
        dbrefs = jsondata[:dbReferences]
        try
            dbrefs = json_value_to_dict_or_array(dbrefs)
        catch

        end
    end

    for dict in commentdicts
        type = dict[:type]
        if type == "FUNCTION"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(func, dict)
            end
        elseif type == "CATALYTIC_ACTIVITY"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(catalytic_activity, dict)
            end
        elseif type == "SUBUNIT"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(subunit, dict)
            end
        elseif type == "SUBCELLULAR_LOCATION"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(subcellular_location, dict)
            end
        elseif type == "INTERACTION"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(interaction, dict)
            end
        elseif type == "TISSUE_SPECIFICITY"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(tissue_specificity, dict)
            end
        elseif type == "POLYMORPHISM"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(polymorphism, dict)
            end
        elseif type == "ALLERGEN"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(allergen, dict)
            end
        elseif type == "MISCELLANEOUS"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(miscellaneous, dict)
            end
        elseif type == "WEBRESOURCE"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(web_resource, dict)
            end
        elseif type == "SIMILARITY"
            try
                json_value_to_dict_or_array(dict)
            catch
                push!(similarity, dict)
            end
        else
            try
                json_value_to_dict_or_array(dict)
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
        datainfo,
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
function showuniprotdata(io, pdata)
    if pdata.dbrefs == OrderedDict[]
        dbref = "None"
    else
        dbref = length(pdata.dbrefs)
    end
    print.(io, "--- Uniprot Data ---\n",
    "Accession: $(pdata.accession)\n", 
    "ID:  $(pdata.id)\n", 
    "Name:  $(pdata.protinfo[:recommendedName][:fullName][:value])\n", 
    "EC Number:  $(pdata.protinfo[:recommendedName][:ecNumber][1][:value])\n",
    "Alternative Name:  $(pdata.protinfo[:alternativeName][1][:fullName][:value])\n",
    "Gene:  $(pdata.gene)\n", 
    "Secondary accession:  $(pdata.secondary_accession)\n\n",
    "Features:  molecule_processing, domains_and_sites, structural, ptm, sequence_information,\n",
                "\t   mutagenesis, variants, topology, other_features\n",
    "Comments:  func, catalytic_activity, subunit, subcellular_location, interaction\n",
                "\t   tissue_specificity, polymorphism, allergen, web_resource, similarity\n", 
                "\t   miscellaneous, other_comments\n",
    "Other Database References:  $(dbref)\n",
    "--------------------\n")
end

import Base: show
Base.show(io::IO, data::UniProtData) = showuniprotdata(io, data)
