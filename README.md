# BioMakie

## Biological plotting utilities for <a href = "https://www.github.com/JuliaPlots/Makie.jl"><img src="https://raw.githubusercontent.com/JuliaPlots/Makie.jl/master/assets/logo.png" alt="Makie.jl" height="30" align = "top"></a>

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kool7d.github.io/BioMakie.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kool7d.github.io/BioMakie.jl/dev)
[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/kool7d/BioMakie.jl?svg=true)](https://ci.appveyor.com/project/kool7d/BioMakie-jl)
[![Codecov](https://codecov.io/gh/kool7d/BioMakie.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kool7d/BioMakie.jl)

## Installation

This package is a set of interactive biological visualizations with Makie at its core.
This package is **in development** and will **break often**.  As it is currently unregistered, you can install it from the REPL like so:
```julia
]add https://github.com/kool7d/BioMakie.jl
```

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID. The following code plots the structure then returns a StructureView with the scene and layout.
```julia
julia> sv = viewstruc("2VB1")
```
![Image of struc](https://github.com/kool7d/BioMakie.jl/blob/master/examples/2vb1.png)

To view the alpha shape (a mesh algorithm) of a PDB structure, use the `viewalphashape` function with a PDB ID. The current version requires
the use of PyCall/Conda, the python interoperation package. The following code imports and attempts to set up PyCall/Conda, then plots the alpha shape and returns a StructureView with the scene and layout.
```julia
julia> sa = viewalphashape("2VB1")
```
![Image of ashape](https://github.com/kool7d/BioMakie.jl/blob/master/examples/2vb1alpha.png)

An example with additional controls can be loaded with `viewanimation`. This
example is still a little laggy, but should work to demonstrate a more
complicated view. It will only work if the previous example works since it
also shows an alpha shape.
```julia
julia> sn = viewanimation()
```
![Image of animation](https://github.com/kool7d/BioMakie.jl/blob/master/examples/2vb1anim.png)

Another example, `viewmsa`, does basically the same thing but for multiple
sequence alignments. (from Pfam) (currently there is a bug in the text display which will be fixed ASAP)
```julia
julia> ms = viewmsa("PF00062")

