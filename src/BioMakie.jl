module BioMakie

export viewstruc, viewmsa

# using BioSequences
using BioStructures
using Colors, ColorSchemes
using DataStructures, DataFrames, DelimitedFiles
using Distances, Distributions
using FileIO, FastaIO, OrderedCollections, SplitApplyCombine, TensorCast
using GeometryBasics
# using GLMakie
using JSServe, WGLMakie
using MIToS
using Observables
# using Phylo
# Node = WGLMakie.Node

include("../src/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
