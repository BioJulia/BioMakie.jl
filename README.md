# BioMakie.jl

## Installation

Julia is required. This package is being developed with Julia 1.7, so some features may not work 
if an earlier version is used. Install the BioMakie master branch from the Julia REPL. Enter the 
package mode by pressing ] and run `add BioMakie#master`.
## Usage

Some examples are shown below, but refer to the rest of the documentation for a more in-depth look.
To view a PDB structure, just use the `plot` function.

```julia
using BioStructures
struc = retrievepdb("2vb1", dir = "data\\") |> Observable
sv = plot(struc)

struc = read("data\\2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
sv = plot(struc)
```

<p align="center"><img width="530" height="600" src="docs/assets/struc.png"></p>

To view a multiple sequence alignment, use the `plot` function with a Pfam MSA or fasta file.

```julia
using MIToS.MSA
downloadpfam("pf00062")
vm = MIToS.MSA.read("pf00062.stockholm.gz",Stockholm) |> Observable
fig1 = plot(vm)

using FastaIO
vm = FastaIO.readfasta("data/fasta1.fas") |> Observable
fig1 = plot(vm)
```

![pf00062x](https://user-images.githubusercontent.com/26263436/141277817-16a4958d-6637-43b0-9946-1916c2947c3a.png)
