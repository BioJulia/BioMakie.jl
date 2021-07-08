# BioMakie

[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)

## Installation and Setup

This package contains visual utilities for biodata, mostly proteins. 

```julia
julia> ] add BioMakie
julia> using BioMakie
```
Basic GLMakie visualizations are implemented but WebGL is under construction.

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID or BioStructures protein structure.
```julia
julia> struc = retrievepdb("2vb1", dir = "data\\")
julia> sv = viewstruc(struc)

julia> struc = read("data\\2vb1_m1.pdb", BioStructures.PDB)
julia> sv = viewstruc(struc)
```
<p align="center">
  <img width="550" height="620" src="docs/src/assets/2vb1.png">
</p>

To view a multiple sequence alignment, use the `viewmsa` function with a Pfam ID or fasta file.
```julia
julia> mv = viewmsa("PF00062")

julia> mv = viewmsa("data/fasta1.fas")
```
![Image of msa](docs/src/assets/pf00062.png)
