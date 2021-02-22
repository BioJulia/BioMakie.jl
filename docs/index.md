```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/master/docs/index.jl"
```

```@meta
CurrentModule = BioMakie
```
# # BioMakie

User interface tools for bioinformatics.

# Description

BioMakie.jl is a package designed to facilitate visual investigation of biological
data. It provides some extra tools to view data of structures and sequences.

BioMakie utilizes other packages in the BioJulia ecosystem like BioStructures.jl,
and outside packages like MIToS.jl. Makie `Node` objects can contain data
and be tracked. This is useful for interactivity and synchronization.

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

```@example
sv = viewstruc("2VB1")
```

To view a multiple sequence alignment, use the `viewmsa` function with a Pfam ID (fasta coming soon)
```@example
mv = viewmsa("PF00062")
```

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
