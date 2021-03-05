```@meta
CurrentModule = BioMakie
```

# BioMakie

## Biological data utilities for <a href = "https://www.github.com/JuliaPlots/Makie.jl"><img src="https://raw.githubusercontent.com/JuliaPlots/Makie.jl/master/assets/logo.png" alt="Makie.jl" height="30" align = "top"></a>

[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)

## Installation and Setup

This package contains interactive biological visualizations and using Makie.
This package is **in development** and not yet "production ready".
If you want to test it out use `add BioMakie#master` instead of `add BioMakie` for the moment.
```julia
julia> ] add BioMakie#master
julia> using BioMakie
```

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID.
```julia
julia> sv = viewstruc("2VB1")
```
![Image of struc](https://github.com/kool7d/BioMakie.jl/blob/master/docs/assets/2vb1.png)

To view a multiple sequence alignment, use the `viewmsa` function with a Pfam ID.
```julia
julia> mv = viewmsa("PF00062")
```
![Image of msa](https://github.com/kool7d/BioMakie.jl/blob/master/docs/assets/pf00062.png)
