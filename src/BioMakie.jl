module BioMakie

export viewstruc

using BioSequences
using BioStructures
using Colors
using ColorSchemes
using DataStructures
using DelimitedFiles
using Distances
using Distributions
using FileIO
using FastaIO
using GeometryBasics
using MIToS.MSA
using MIToS.Information
using MIToS.SIFTS
using MIToS.PDB
using MIToS.Pfam
using SplitApplyCombine
using TensorCast
using GLMakie
using WGLMakie
Node = GLMakie.Node

include("../data/chemdata.jl")
include("../src/utils.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
# include("../src/msa.jl")

end # BioMakie
