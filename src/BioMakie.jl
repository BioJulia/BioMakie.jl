module BioMakie

export protsmiles,
       getplottingdata,
       msavalues,
       plotmsa!,
       plotmsa,
       atomradii,
       atomradius,
       plotstruc!,
       plotstruc,
       distancebonds,
       covalentbonds,
       sidechainbonds,
       backbonebonds,
       getbonds,
       bondshape,
       bondshapes,
       elecolors,
       cpkcolors, 
       aquacolors, 
       shapelycolors, 
       leskcolors, 
       maecolors, 
       cinemacolors,
       getbiocolors

using BioStructures, MolecularGraph
using MIToS, MIToS.Information, MIToS.MSA, MIToS.Pfam, MIToS.SIFTS, MIToS.Utils
using SplitApplyCombine, TensorCast
using DataStructures, DelimitedFiles, OrderedCollections
using Distances, GeometryBasics
using Colors, ColorSchemes, ColorTypes, ImageCore
using FileIO, FastaIO, FASTX
using HTTP, JSON3
using GLMakie
GLMakie.activate!()

include("../src/utils.jl")
include("../src/chemdata.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/dbinfo.jl")
include("../src/otherplots.jl")
include("../src/msa.jl")

end # BioMakie
