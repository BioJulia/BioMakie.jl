module BioMakie

export protsmiles,
       getplottingdata,
       msavalues,
       plotmsa!,
       plotmsa,
       plotstruc!,
       plotstruc
#

using BioStructures, MolecularGraph
using MIToS, MIToS.Information, MIToS.MSA, MIToS.Pfam, MIToS.SIFTS, MIToS.Utils
using SplitApplyCombine, TensorCast
using DataStructures, DelimitedFiles, HTTP
using Distances, Distributions, GeometryBasics
using Colors, ColorSchemes, ColorTypes, ImageCore
using FileIO, FastaIO, FASTX, OrderedCollections
using JSServe
using GLMakie
GLMakie.activate!()

include("../src/utils.jl")
include("../src/chemdata.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
