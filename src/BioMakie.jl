module BioMakie

export viewstruc, viewmsa, StructureView, MSAView

using AbstractPlotting
using BioSequences
using BioStructures
using Colors, ColorSchemes
using DataStructures
using DelimitedFiles
using Distances
using Distributed
using FileIO
using GeometryBasics
using GLFW, GLMakie
using JLD2
using Lazy
using MIToS
using MIToS.MSA: AbstractMultipleSequenceAlignment, Stockholm
using MakieLayout
using MacroTools
using Phylo
using SplitApplyCombine
using TensorCast
Node = AbstractPlotting.Node

include("../data/basicdata.jl")
include("utils.jl")
include("bonds.jl")
include("structure.jl")
include("msa.jl")

end # BioMakie
