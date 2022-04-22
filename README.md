# BioMakie.jl

## Installation

Julia is required. This package is being developed with Julia 1.7, so some features may not work 
if an earlier version is used. Install the BioMakie master branch from the Julia REPL. Enter the 
package mode by pressing ] and run `add BioMakie#master`.

## Usage

To view a protein, use the `plotstruc` function with a BioStructures PDB structure.

```julia
using BioStructures
struc = retrievepdb("2vb1", dir = "data\\") |> Observable
# or #
struc = read("data\\2vb1_mutant1.pdb", BioStructures.PDB) |> Observable

fig = Figure()
plotstruc!(fig, struc; plottype = :spacefilling, gridposition = (1,1), atomcolors = aquacolors)
plotstruc!(fig, struc; plottype = :covalent, gridposition = (1,2))
```
<p align="center"><img src="assets/vdwcov.png"></p>

To view a multiple sequence alignment, use the `plotmsa` function with a Pfam MSA or fasta file.

```julia
using MIToS.MSA
downloadpfam("pf00062")
msa = MIToS.MSA.read("pf00062.stockholm.gz",Stockholm) |> Observable
# or #
using FastaIO
msa = FastaIO.readfasta("data/fasta1.fas") |> Observable

msamatrix, xlabel, ylabel = getplottingdata(msa1) .|> Observable
msafig, plotdata... = plotmsa(msamatrix;
				xlabels = xlabel, 	
				ylabels = ylabel, colorscheme = :buda)
```
<p align="center"><img src="assets/msa.png"></p>

## Additional examples

Documentation for advanced plotting will be available soon. 
Selection and multiple plots linked:
<p align="center"><img src="assets/selectres.png"></p>

Animation of a mesh through different trajectories:
<p align="center"><img src="assets/shapeanimation.gif"></p>
