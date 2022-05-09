module BioMakie

export resmass,
       resvdw,
       elecolors,
       aquacolors,
       SMILESaa,
       protsmiles,
       kideradict,
       distancebonds,
       covalentbonds,
       sidechainbonds,
       backbonebonds,
       getbonds,
       bondshape,
       bondshapes,
       getplottingdata,
       msavalues,
       plotmsa!,
       plotmsa,
       atomcoords,
       atomradii,
       plotstruc!,
       plotstruc,
       atomicmasses,
       covalentradii,
       vanderwaalsradii,
       resletterdict,
       downloadpfam
#

using BioStructures, MolecularGraph
using MIToS, MIToS.Information, MIToS.MSA, MIToS.Pfam, MIToS.SIFTS, MIToS.Utils
using SplitApplyCombine, TensorCast
using DataStructures, DelimitedFiles, HTTP
using Distances, Distributions, GeometryBasics, Colors
using FileIO, FastaIO, FASTX, OrderedCollections
using JSServe
# using Makie, Meshes, Graphs
using GLMakie
using GLMakie: @lift, Observable, lift
GLMakie.activate!()

include("../src/utils.jl")
include("../src/chemdata.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie