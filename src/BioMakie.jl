module BioMakie

using DelimitedFiles, JLD2, TensorCast,
        MacroTools, Lazy, Distances, Distributed, DataStructures,
        CairoMakie, GLFW, GLMakie, Makie, MakieLayout,
        BioSequences, BioStructures, MIToS
include("utils.jl")

abstract type AbstractTether <:StructuralElement end
abstract type AbstractBond <:AbstractTether end
abstract type AbstractHinge <:AbstractTether end

mutable struct Tether{T} <:AbstractTether where {T<:StructuralElementOrList}
	points::T
end
mutable struct Bond <:AbstractTether where {T<:StructuralElementOrList}
	atoms::T
end
Bond(x1::StructuralElement, x2::StructuralElement) = Bond([x1,x2])
atoms(bond::Bond) = bond.atoms
points(tether::AbstractTether) = tether.points

end # BioMakie
