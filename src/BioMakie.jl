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
#

using BioStructures, MolecularGraph
using MIToS, MIToS.Information, MIToS.MSA, MIToS.Pfam, MIToS.SIFTS, MIToS.Utils
using SplitApplyCombine, TensorCast
using DataStructures, DelimitedFiles, HTTP
using Distances, Distributions, GeometryBasics
using Colors, ColorSchemes, ColorTypes, ImageCore
using FileIO, FastaIO, FASTX, OrderedCollections
using Makie
using JSServe
using GLMakie
GLMakie.activate!()

include("../src/utils.jl")
include("../src/chemdata.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie
