module BioMakie

export viewstruc, viewmsa

using BioStructures, MolecularGraph
using Colors, ColorSchemes, Lazy
using DataStructures, DataFrames, DelimitedFiles, JLD2
using Distances, Distributions
using FileIO, FastaIO, OrderedCollections, SplitApplyCombine, TensorCast
using GeometryBasics, Meshes, MeshViz
using GLMakie, WGLMakie, GraphMakie, JSServe
using Observables
GLMakie.activate!()

include("../src/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl") 
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
