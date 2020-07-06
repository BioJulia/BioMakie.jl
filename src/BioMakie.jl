module BioMakie

using JLD2, MacroTools, Lazy, Distances, Distributed, SplitApplyCombine,
        GeometryBasics, Makie, MakieLayout, Colors, ColorSchemes, GLFW,# JSServe,
        BioSequences, BioStructures

abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end
abstract type AbstractHinge <:AbstractTether end

include("../data/basicdata.jl")
include("utils.jl")
include("bonds.jl")
include("proteins.jl")

end # BioMakie
