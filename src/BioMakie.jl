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
	   resletterdict

using BioStructures, MolecularGraph, MIToS
using MIToS.Information, MIToS.MSA, MIToS.Pfam, MIToS.SIFTS, MIToS.Utils
using SplitApplyCombine, TensorCast
using DataStructures, DelimitedFiles, HTTP
using Distances, Distributions, GeometryBasics, Colors
using FileIO, FastaIO, OrderedCollections
using GraphMakie, JSServe, Meshes
using GLMakie, WGLMakie
GLMakie.activate!()
using GLMakie: @lift

include("../src/utils.jl")
include("../src/chemdata.jl")
include("../src/bonds.jl")
include("../src/structure.jl")
include("../src/msa.jl")

end # BioMakie