# BioMakie

## Biological data utilities for <a href = "https://www.github.com/JuliaPlots/Makie.jl"><img src="https://raw.githubusercontent.com/JuliaPlots/Makie.jl/master/assets/logo.png" alt="Makie.jl" height="30" align = "top"></a>

[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)

## Installation and Setup

This package contains interactive biological visualizations and using Makie.

```julia
julia> ] add BioMakie
julia> using BioMakie
```
Basic GLMakie visualizations are implemented but WebGL is under construction.

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID or BioStructures protein structure.
```julia
julia> struc = retrievepdb("2vb1", dir = "data\\") |> Node
julia> sv = viewstruc(struc)

julia> struc = read("data\\2vb1_m1.pdb", BioStructures.PDB) |> Node
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
