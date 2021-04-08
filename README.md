# BioMakie

## Biological data utilities for <a href = "https://www.github.com/JuliaPlots/Makie.jl"><img src="https://raw.githubusercontent.com/JuliaPlots/Makie.jl/master/assets/logo.png" alt="Makie.jl" height="30" align = "top"></a>

[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)

## Installation and Setup

This package contains interactive biological visualizations and using Makie.

```julia
julia> ] add BioMakie
julia> using BioMakie
```

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID or BioStructures protein structure.
```julia
julia> sv = viewstruc("2VB1")
```
```julia
julia> struc = retrievepdb("2vb1", dir = "data\\")
julia> sv = viewstruc(struc)
```
```julia
julia> struc = read("data\\2vb1_m1.pdb", BioStructures.PDB)
julia> sv = viewstruc(struc)
```
![Image of struc](https://github.com/kool7d/BioMakie.jl/blob/master/docs/assets/2vb1.png)

To view a multiple sequence alignment, use the `viewmsa` function with a Pfam ID or fasta file.
```julia
julia> mv = viewmsa("PF00062")
```
```julia
julia> mv = viewmsa("data/fasta1.fas")
```
![Image of msa](https://github.com/kool7d/BioMakie.jl/blob/master/docs/assets/pf00062.png)
