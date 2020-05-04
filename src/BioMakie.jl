# module BioMakie

using DelimitedFiles, JLD2, TensorCast,
        MacroTools, Lazy, Distances, Distributed, DataStructures,
        GeometryBasics, GLFW, GLMakie, MakieLayout,
        BioSequences, BioStructures, MIToS
abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end
abstract type AbstractHinge <:AbstractTether end
include("basicdata.jl")
include("utils.jl")
include("proteins.jl")
include("hinges.jl")
include("bonds.jl")

# end # BioMakie
