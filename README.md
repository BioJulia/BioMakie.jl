# BioMakie

## Biological plotting utilities for <a href = "https://www.github.com/JuliaPlots/Makie.jl"><img src="https://raw.githubusercontent.com/JuliaPlots/Makie.jl/master/assets/logo.png" alt="Makie.jl" height="30" align = "top"></a>

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kool7d.github.io/BioMakie.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kool7d.github.io/BioMakie.jl/dev)
[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/kool7d/BioMakie.jl?svg=true)](https://ci.appveyor.com/project/kool7d/BioMakie-jl)
[![Codecov](https://codecov.io/gh/kool7d/BioMakie.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kool7d/BioMakie.jl)

## Installation

This package is **in development** and will **break often**.  As it is currently unregistered, you can install it from the REPL like so:
```julia
]add https://github.com/kool7d/BioMakie.jl

To view a PDB structure, use the `viewstruc` function with a PDB ID. The following code
plots the structure then returns a StructureView with relevant Nodes, the scene, and the layout
for convenience.
```julia
julia> sv = viewstruc("2VB1") # plots the structure and returns a StructureView
```
