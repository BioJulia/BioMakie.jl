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
# default Makie backend is GLMakie.jl. So far, plotting methods exist for packages: 
# - BioStructures.jl
# - MIToS.jl

# The main plotting functions are **plotstruc** and **plotmsa**, along with their mutating 
# versions, **plotstruc!** and **plotmsa!**. The mutating functions allow the user to add multiple 
# plots to the same Figure, using grid positions.

cd("docs/src/assets/") # hide
# using GLMakie: lift, @lift, Observable # hide
using BioMakie
using GLMakie
using BioStructures
struc = retrievepdb("2vb1") |> Observable
## or
struc = read("2vb1.pdb", BioStructures.PDB) |> Observable
#-
fig = Figure()
plotstruc!(fig, struc; plottype = :ballandstick, gridposition = (1,1), atomcolors = aquacolors)
plotstruc!(fig, struc; plottype = :covalent, gridposition = (1,2))
nothing # hide
save("2vb1.png", fig) # hide

# ![strucs](2vb1.png)

# ### Multiple Sequence Alignments

# Multiple Sequence Alignments (MSAs) are plotted using a matrix of residue letters, and a
# matrix of values for the heatmap colors. If only a matrix of letters is provided as input,
# colors will be automatic. MSA objects from MIToS have specific support, as well as Fasta files
# loaded with FastaIO.jl or FASTX.jl.

# To view a multiple sequence alignment, use the `plotmsa` or `plotmsa!` function with a Pfam MSA or fasta file.

using FASTX
reader = open(FASTX.FASTA.Reader, "PF00062_full.fasta")
msa = [reader...] |> Observable
close(reader)
## or 
using MIToS
using MIToS.MSA
msa = MIToS.MSA.read("pf00062.stockholm.gz",Stockholm)

fig = plotmsa(msa; colorscheme = :tableau_blue_green)
nothing # hide

# ![MSA](msa.png)

# ## Additional examples

# Alpha shapes can be used to visualize the surface of a protein structure

# ![alphashape](alphashape.png)
