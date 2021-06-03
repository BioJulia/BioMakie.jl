module BioMakie

export viewstruc, viewmsa

# using BioSequences
# using AbstractPlotting
using BioStructures
using Colors, ColorSchemes, Lazy
using DataStructures, DataFrames, DelimitedFiles
using Distances, Distributions
using FileIO, FastaIO, OrderedCollections, SplitApplyCombine, TensorCast
using GeometryBasics
using GLMakie
using Observables

include("../src/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
