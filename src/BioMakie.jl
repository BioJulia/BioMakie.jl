module BioMakie

using BioStructures, MolecularGraph, MIToS
using Lazy, SplitApplyCombine, TensorCast
using DataStructures, DelimitedFiles, JLD2, JSON3, HTTP
using Distances, Distributions, GeometryBasics, Colors
using FileIO, FastaIO, OrderedCollections
using GraphMakie, JSServe, WGLMakie
using Observables, Meshes, GLMakie
using WGLMakie.Makie
using Makie: push!
GLMakie.activate!()

include("../src/utils.jl")
include("../src/chemdata.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")
include("../src/downloaders.jl")

end # BioMakie
