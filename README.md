# BioMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kool7d.github.io/BioMakie.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kool7d.github.io/BioMakie.jl/dev)
[![Build Status](https://travis-ci.com/kool7d/BioMakie.jl.svg?branch=master)](https://travis-ci.com/kool7d/BioMakie.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/kool7d/BioMakie.jl?svg=true)](https://ci.appveyor.com/project/kool7d/BioMakie-jl)
[![Codecov](https://codecov.io/gh/kool7d/BioMakie.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kool7d/BioMakie.jl)

This package is a set of interactive biological visualizations with Makie at its core.

To view a PDB structure, use the `viewstruc` function with a PDB ID. The following code
plots the structure then returns a StructureView, a Scene, and a GridLayout to work with.
```julia
julia> sv = viewstruc("6LZG") # plots the structure, returns a StructureView, Scene, and a GridLayout
```
