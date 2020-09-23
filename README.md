# BioMakie

## Biological plotting utilities for <a href = "https://www.github.com/JuliaPlots/Makie.jl"><img src="https://raw.githubusercontent.com/JuliaPlots/Makie.jl/master/assets/logo.png" alt="Makie.jl" height="30" align = "top"></a>

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kool7d.github.io/BioMakie.jl/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kool7d.github.io/BioMakie.jl/)
[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/8qai95k40qpvua74/branch/master?svg=true)](https://ci.appveyor.com/project/kool7d/biomakie-jl/branch/master)
[![Codecov](https://codecov.io/gh/kool7d/BioMakie.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kool7d/BioMakie.jl)

## Installation and Setup

This package is a set of interactive biological visualizations with Makie.
This package is **in development** and will **break often**.

```julia
julia> ] add BioMakie
julia> using BioMakie
```

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID. The following code plots the structure then returns a StructureView with the scene and layout.
```julia
julia> sv = viewstruc("2VB1")
```
![Image of struc](https://github.com/kool7d/BioMakie.jl/blob/master/assets/2vb1.png)

You could also look at multiple structures at once.
```julia
julia> svs = viewstrucs(["2vb1","1lw3"], colors = ["aqua","ele"])
```
![Image of strucs](https://github.com/kool7d/BioMakie.jl/blob/master/assets/2strucs.png)

To view a multiple sequence alignment, use the `viewmsa` function with a Pfam ID (fasta coming soon).
```julia
julia> mv = viewmsa("PF00062")
```
![Image of msa](https://github.com/kool7d/BioMakie.jl/blob/master/assets/pf00062.png)

Animation and more sophisticated visualizations are also possible.

![Image of anim](https://github.com/kool7d/BioMakie.jl/blob/master/assets/shapeanimation.mp4)
