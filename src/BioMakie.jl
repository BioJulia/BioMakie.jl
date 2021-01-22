module BioMakie

export viewstruc, viewmsa, StructureView, MSAView

using BioSequences
using BioStructures
using Colors, ColorSchemes
using DataStructures
using DelimitedFiles
using Distances
using Distributions
using FileIO
using GeometryBasics
using MIToS
using SplitApplyCombine
using TensorCast
using GLMakie

include("../data/basicdata.jl")
include("../data/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
