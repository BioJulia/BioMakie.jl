module BioMakie

export viewstruc, viewmsa, StructureView, MSAView

using AbstractPlotting
using BioStructures
using Colors, ColorSchemes
using DataStructures
using DelimitedFiles
using Distances
using Distributed
using FileIO
using GeometryBasics
using JLD2
using Lazy
using MIToS
using MIToS.MSA: AbstractMultipleSequenceAlignment, Stockholm
using MacroTools
using SplitApplyCombine
using TensorCast
using GLMakie
# using WGLMakie
Node = AbstractPlotting.Node

include("../data/basicdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
