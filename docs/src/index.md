```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/dev/docs/src/index.md"
```
<p align="center"><img src="docs/src/assets/biomakiename1.png" width="400" height="79"></p>

[![Latest release](https://img.shields.io/github/release/kool7d/BioMakie.jl.svg)](https://github.com/kool7d/BioMakie.jl/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kool7d/BioMakie.jl/blob/master/LICENSE.md)
[![Build Status](https://github.com/kool7d/BioMakie.jl/workflows/ci/badge.svg)](https://github.com/kool7d/BioMakie.jl/actions?query=workflow%3Aci) 
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/kool7d/BioMakie.jl/master?label=last%20commit%20%7C%20master)

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg?label=documentation)](https://kool7d.github.io/BioMakie.jl/dev)

<!-- [![codecov.io](http://codecov.io/github/kool7d/BioMakie.jl/coverage.svg?branch=master)](http://codecov.io/github/kool7d/BioMakie.jl?branch=master) -->

### A new version will soon be released (v0.2.3 -> v0.3.0) which introduces many new features, bugfixes, and breaking changes. The package is also planned to be moved into the BioJulia organization. Stay tuned...

## Installation
 
Enter the package mode by pressing ] and run `add BioMakie`. 
To get the latest features that may not be in the current release, run `add BioMakie#master`.

## About

This package provides plotting functions for protein structures, multiple sequence alignments, and some other related plots like protein structure contact maps.
The main plotting functions are **plotstruc** and **plotmsa**, along with their mutating versions, **plotstruc!** and **plotmsa!**.

```julia
using BioMakie
using GLMakie
using BioStructures
struc = retrievepdb("2vb1") |> Observable
## or
struc = read("2vb1.pdb", BioStructures.PDB) |> Observable

fig = Figure()
plotstruc!(fig, struc; plottype = :ballandstick, gridposition = (1,1), atomcolors = aquacolors)
plotstruc!(fig, struc; plottype = :covalent, gridposition = (1,2))
```
<p align="center"><img src="docs/src/assets/2vb1crop.png"></p>

To view a multiple sequence alignment, use the `plotmsa` function with a Pfam MSA or fasta file.

```julia
using FASTX
reader = open(FASTX.FASTA.Reader, "PF00062_full.fasta")
msa = [reader...] |> Observable
close(reader)
## or 
using MIToS
using MIToS.MSA
msa = MIToS.MSA.read("pf00062.stockholm.gz", Stockholm)

fig = plotmsa(msa; colorscheme = :tableau_blue_green)
```
<p align="center"><img src="docs/src/assets/msa.png"></p>

### Implemented packages:
Significant or full coverage: 
 - BioStructures.jl
 - MIToS.jl
 - FastaIO.jl
 - FASTX.jl

Some coverage:
 - MolecularGraph.jl
 - ProtoSyn.jl

### Implemented visualizations:
- Structures
  - Ball and stick, spacefilling, covalent representations
  - Selections
  - Alpha shapes
- Multiple sequence alignments
  - Grid display
  - Selections
  - Frequency plot
- Data acquisition from `www.ebi.ac.uk` and display 

### To Do:
- Support for non-standard and modified amino acids
- Connect MSA and structure plot
- Protein dynamics