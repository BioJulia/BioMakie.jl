module BioMakie

export  bondshape,
        resletterdict,
        viewmsa,
		atomcolors,
        atomcoords,
        atomradii, 
		viewstruc,
        resatoms,
        resbonds,
        backbonebonds,
        defaultatom,
        defaultresidue,
        covrad,
        vdwrad

using BioStructures, MolecularGraph, MIToS
using SplitApplyCombine, TensorCast
using DataStructures, DelimitedFiles, HTTP
using Distances, Distributions, GeometryBasics, Colors
using FileIO, FastaIO, OrderedCollections
using GraphMakie, JSServe, Meshes
using GLMakie, WGLMakie
GLMakie.activate!()
using GLMakie: @lift

include("../src/utils.jl")
include("../src/chemdata.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie