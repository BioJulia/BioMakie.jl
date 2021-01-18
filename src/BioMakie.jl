module BioMakie

export viewstruc, viewmsa, StructureView, MSAView

using AbstractPlotting
using BioSequences
using BioStructures
using Colors, ColorSchemes
using DataStructures
using DelimitedFiles
using Distances
using FileIO
using MIToS
using SplitApplyCombine
using TensorCast
using GLMakie

include("../data/basicdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
