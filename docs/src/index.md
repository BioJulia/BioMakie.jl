```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/master/src/index.jl"
```

```@meta
CurrentModule = BioMakie
```
# BioMakie

BioMakie.jl is a package designed to facilitate visual investigation of biological
data.

BioMakie utilizes other packages in the BioJulia ecosystem like BioStructures.jl,
and outside packages like MIToS.jl.

For more examples of what Makie can do, visit the documentation at
https://makie.juliaplots.org/stable/

# Setup

```@example index
# in the REPL
]add BioMakie

# elsewhere
using Pkg
Pkg.add("BioMakie")

# import the package
using BioMakie
```

# Basic Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID.

using JSServe
Page(exportable=true, offline=true)
```

```@example index
sv = viewstruc("2VB1")
```

![Image of struc](../assets/2vb1.png)

![Image of strucc](2vb1.png)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
