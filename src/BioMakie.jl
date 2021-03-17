module BioMakie

export viewstruc, viewmsa

# using BioSequences
using BioStructures
using Colors
using ColorSchemes
using DataStructures
using DataFrames
using DelimitedFiles
using Distances
using Distributions
using FileIO
using FastaIO
using GeometryBasics
using GLMakie
# using JSServe
using MIToS
using MIToS.MSA
using MIToS.Information
using MIToS.SIFTS
using MIToS.PDB
using MIToS.Pfam
using MIToS.Utils
using OrderedCollections
using SplitApplyCombine
using TensorCast
# using WGLMakie

include("../data/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
