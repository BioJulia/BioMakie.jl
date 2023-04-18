```@meta
EditURL = "<unknown>/src/index.jl"
```

# BioMakie.jl

This package provides plotting functions for protein structures, multiple sequence alignments, and some
other related plots like protein structure contact maps.

So far, plotting methods exist for packages:
- BioStructures.jl
- MIToS.jl
- FastaIO.jl
- FASTX.jl

Other packages with plotting methods in development:
- MolecularGraph.jl
- ProtoSyn.jl

## Installation

Enter the package mode by pressing ] and run `add BioMakie`.

## Usage

The main plotting functions are **plotstruc** and **plotmsa**, along with their mutating
versions, **plotstruc!** and **plotmsa!**. The mutating functions allow the user to add multiple
plots to the same Figure, using grid positions.

### Structure

There are different representations for protein structures, including "ball and stick"
(**:ballandstick**), "covalent" (**:covalent**), and "space filling" (**:spacefilling**). The
default Makie backend is GLMakie.jl, but some of the functions work with WGLMakie.

````@example index
cd("docs/src/assets/") # hide
````

using GLMakie: lift, @lift, Observable # hide

````@example index
using BioMakie
using GLMakie
using BioStructures
struc = retrievepdb("2vb1") |> Observable
# or
struc = read("2vb1.pdb", BioStructures.PDB) |> Observable
````

````@example index
fig = Figure()
plotstruc!(fig, struc; plottype = :ballandstick, gridposition = (1,1), atomcolors = aquacolors)
plotstruc!(fig, struc; plottype = :covalent, gridposition = (1,2))
nothing # hide
````

![strucs](2vb1.png)

### Multiple Sequence Alignments

Multiple Sequence Alignments (MSAs) are plotted using a matrix of residue letters, and a
matrix of values for the heatmap colors. If only a matrix of letters is provided as input,
colors will be automatic. MSA objects from MIToS have specific support, as well as Fasta files
loaded with FastaIO.jl or FASTX.jl.

To view a multiple sequence alignment, use the `plotmsa` or `plotmsa!` function with a Pfam MSA or fasta file.

````@example index
using FASTX
reader = open(FASTX.FASTA.Reader, "PF00062_full.fasta")
msa = [reader...] |> Observable
close(reader)
# or
using MIToS
using MIToS.MSA
msa = MIToS.MSA.read("pf00062.stockholm.gz", Stockholm)

fig = plotmsa(msa; colorscheme = :tableau_blue_green)
nothing # hide
````

![MSA](msa.png)

## Additional examples

Alpha shapes can be used to visualize the surface of a protein structure

![alphashape](alphashape.png)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

