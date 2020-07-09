module BioMakie

using JLD2, MacroTools, Lazy, Distances, DataStructures, Distributed, SplitApplyCombine,
        GeometryBasics, GLMakie, Makie, MakieLayout, Colors, ColorSchemes, GLFW,# JSServe,
        BioSequences, BioStructures, MIToS

abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end
abstract type AbstractHinge <:AbstractTether end

include("../data/basicdata.jl")
include("utils.jl")
include("bonds.jl")
include("loadframes.jl")
include("proteins.jl")

end # BioMakie
