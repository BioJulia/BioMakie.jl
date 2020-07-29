module BioMakie

using JLD2, MacroTools, Lazy, Distances, DataStructures, Distributed,
        SplitApplyCombine, GeometryBasics, Makie, MakieLayout, Colors,
        ColorSchemes, GLFW, FileIO, DelimitedFiles,
        GLMakie, BioSequences, BioStructures, MIToS

abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end

include("../data/basicdata.jl")
include("utils.jl")
include("bonds.jl")
include("proteins.jl")

end # BioMakie
