module BioMakie

using DelimitedFiles, JLD2, TensorCast,
        MacroTools, Lazy, Distances, Distributed, DataStructures, SplitApplyCombine,
        GeometryBasics, Makie, MakieLayout, Colors, ColorSchemes, GLFW,#StatsMakie, JSServe,
        BioSequences, BioStructures, MIToS
abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end
abstract type AbstractHinge <:AbstractTether end
include("../data/basicdata.jl")
include("utils.jl")
include("proteins.jl")
include("hinges.jl")
include("bonds.jl")
include("phylogeny.jl")

# end # BioMakie
