module BioMakie

export viewstruc, viewmsa

using BioStructures, MolecularGraph, MIToS
using Colors, Lazy
using DataStructures, DataFrames, DelimitedFiles, JLD2
using Distances, Distributions, GeometryBasics
using FileIO, FastaIO, OrderedCollections, SplitApplyCombine, TensorCast
using GLMakie, JSServe#, CairoMakie, WGLMakie, GraphMakie
using Observables, Meshes, MeshViz
using GLMakie: @lift, lift
GLMakie.activate!()

include("../src/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
