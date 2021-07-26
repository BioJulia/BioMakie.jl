module BioMakie

export viewstruc, viewmsa

using BioStructures, MolecularGraph, MIToS
using Colors, Lazy
using DataStructures, DelimitedFiles, JLD2, HTTP
using Distances, Distributions, GeometryBasics
using FileIO, FastaIO, OrderedCollections, SplitApplyCombine, TensorCast
using Makie, JSServe, GraphMakie
using Observables, Meshes, MeshViz
using GLMakie
GLMakie.activate!()

include("../src/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
