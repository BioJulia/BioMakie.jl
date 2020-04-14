module BioMakie

using DelimitedFiles, JLD2, TensorCast,
        MacroTools, Lazy, Distances, Distributed, DataStructures,
        GeometryTypes, GeometryBasics, GLFW, GLMakie, Makie, MakieLayout, MeshIO,
        BioSequences, BioStructures, MIToS
abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end
abstract type AbstractHinge <:AbstractTether end
include("utils.jl")
include("proteins.jl")
include("hinges.jl")
include("bonds.jl")


end # BioMakie
