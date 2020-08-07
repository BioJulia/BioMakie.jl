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
using SplitApplyCombine
using TensorCast

abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end

include("../data/basicdata.jl")
include("utils.jl")
include("bonds.jl")
include("proteins.jl")
include("../examples/src/kiderafactors.jl")
include("msa.jl")
# # Requires the use of PyCall/Conda, the python interoperation package:
# include("../examples/alphashape.jl")
# include("../examples/shapeanimation.jl")

end # BioMakie
