```@meta
EditURL = "<unknown>/src/index.jl"
```

```@meta
CurrentModule = BioMakie
```
# BioMakie

User interface tools for bioinformatics.

## Description

BioMakie.jl is a package designed to facilitate visual investigation of biological
data. BioMakie utilizes objects from packages in the BioJulia ecosystem like BioStructures.jl,
and outside packages like MIToS.jl to load data and to do most of the setup.

For more examples of what Makie can do, visit the documentation at
https://makie.juliaplots.org/stable/

## Setup

```@example index
using Pkg
Pkg.add("BioMakie")

# import the package
using BioMakie
```

## Basic Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID.

```@example index
sv = viewstruc("2VB1")
```

![Image of struc](../assets/2vb1.png)

You could also look at multiple structures at once.

```@example index
svs = viewstrucs(["2vb1","1lw3"])
```

![Image of strucs](assets/2strucs.png)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

