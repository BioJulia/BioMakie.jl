# # BioMakie.jl

# ## Installation

# Julia is required. This package is being developed with Julia 1.7, so some features may not work 
# if an earlier version is used. Install the BioMakie master branch from the Julia REPL. Enter the 
# package mode by pressing ] and run:

# `add BioMakie`.

# ## Usage

# ### Structure

# There are different representations for protein structures, including "ball and stick"
# (**:ballandstick**), "covalent" (**:covalent**), and "space filling" (**:spacefilling**). The 
# default Makie backend is GLMakie.jl. So far, plotting methods exist specifically for dealing with 
# BioStructures objects like ProteinStructure and Chain. 

# The main plotting functions are **plotstruc** and **plotmsa**, along with their mutating 
# versions, **plotstruc!** and **plotmsa!**. The mutating functions allow the user to add multiple 
# plots to the same Figure, using grid positions.

using GLMakie # hide
GLMakie.activate!() # hide
set_theme!(resolution=(800, 400)) # hide
using GLMakie: lift, @lift, Observable # hide
using BioMakie
using BioStructures
struc = retrievepdb("2vb1"; dir = "assets/") |> Observable
## or
struc = read("assets/2vb1.pdb", BioStructures.PDB) |> Observable
#-
fig = Figure()
plotstruc!(fig, struc; plottype = :spacefilling, gridposition = (1,1), atomcolors = aquacolors)
plotstruc!(fig, struc; plottype = :covalent, gridposition = (1,2))
nothing # hide

# ![strucs](assets/vdwcov.png)

# ### Multiple Sequence Alignments

# Multiple Sequence Alignments (MSAs) are plotted using a matrix of residue letters, and a
# matrix of values for the heatmap colors. If only a matrix of letters is provided as input,
# colors will be automatic. MSA objects from MIToS have specific support, as well as Fasta files
# loaded with FastaIO.jl or [FASTX.jl].

# To view a multiple sequence alignment, use the `plotmsa` or `plotmsa!` function with a Pfam MSA or fasta file.

using MIToS # hide
using MIToS.MSA
msa = MIToS.MSA.read("assets/pf00062.stockholm.gz",Stockholm) |> Observable
## or 
using FASTX
reader = open(FASTX.FASTA.Reader, "assets/PF00062_full.fasta")
msa = [record for record in reader]
close(reader)

msamatrix, xlabel, ylabel = getplottingdata(msa) .|> Observable
msafig, plotdata... = plotmsa(msamatrix;
				xlabels = xlabel, 	
				ylabels = ylabel, colorscheme = :buda)
nothing # hide

# ![MSA](assets/msa.png)

# ## Additional examples

# Multiple sequence alignments can be connected to corresponding protein structures, so columns 
# selected in the MSA will be selected on the protein structure, if the structure has a residue
# for that position. 

# ![MSA-struc connect](assets/selectres.png)

# Animation of a mesh through different trajectories:

# ![shape animate](assets/shapeanimation.gif)
