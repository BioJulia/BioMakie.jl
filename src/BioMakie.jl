module BioMakie

export viewstruc, viewmsa, StructureView, MSAView

using JLD2, MacroTools, Lazy, Distances, DataStructures, Distributed,
        SplitApplyCombine, GeometryBasics, AbstractPlotting, MakieLayout, Colors,
        ColorSchemes, GLFW, FileIO, DelimitedFiles, TensorCast,
        GLMakie, BioSequences, BioStructures, MIToS

abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end

include("../data/basicdata.jl")
include("utils.jl")
include("bonds.jl")
include("proteins.jl")
include("msa.jl")
include("../examples/src/kiderafactors.jl")
# # Requires the use of PyCall/Conda, the python interoperation package:
# include("../examples/alphashape.jl")
# include("../examples/shapeanimation.jl")

end # BioMakie
