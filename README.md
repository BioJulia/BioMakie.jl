# BioMakie

[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)

## Installation and Setup

This package contains visual utilities for biodata, mostly proteins. 

```julia
julia> ] add BioMakie
julia> using BioMakie
```

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID or BioStructures protein structure.
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
