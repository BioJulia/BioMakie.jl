#md # ```@meta
#md # CurrentModule = BioMakie
#md # ```
# # BioMakie

# A user interface for bioinformatics.

# ## Description

# BioMakie.jl is a package designed to facilitate visual investigation of biological
# data. It provides extra tools to view and measure differences between data
# of such things as protein structures and sequences.
#
# BioMakie utilizes objects from packages in the BioJulia ecosystem like BioStructures.jl,
# and outside packages like MIToS.jl to load data and to do most of the setup.
#
# For more examples of what Makie can do, visit the documentation at
# https://makie.juliaplots.org/stable/

# ## Setup

using Pkg
Pkg.add("BioMakie")

## import the package
using BioMakie

# ## Basic Usage

# To view a PDB structure, use the `viewstruc` function with a PDB ID.

sv = viewstruc("2VB1")
#md # ![Image of struc](../assets/2vb1.png)

# You could also look at multiple structures at once.
svs = viewstrucs(["2vb1","1lw3"])
#md # ![Image of strucs](assets/2strucs.png)

# using Literate #src
# Literate.markdown("src/index.jl","src") #src
