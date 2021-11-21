# BioMakie

## Installation and Setup

This package contains visual utilities for biodata, mostly proteins.
At the moment it might be best to add the package like so:

```julia
julia> ] add 'https://github.com/kool7d/BioMakie.jl'
julia> using BioMakie
```

## Usage

To view a PDB structure, use the `viewstruc` function.

```julia
using BioStructures
struc = retrievepdb("2vb1", dir = "data\\") |> Node
sv = viewstruc(struc)

struc = read("data\\2vb1_mutant1.pdb", BioStructures.PDB) |> Node
sv = viewstruc(struc)
```

<p align="center"><img width="530" height="600" src="docs/assets/struc.png"></p>

To view a multiple sequence alignment, use the `viewmsa` function with a Pfam MSA or fasta file.

```julia
using MIToS.MSA
downloadpfam("pf00062")
vm = MIToS.MSA.read("pf00062.stockholm.gz",Stockholm) |> Node
fig1 = viewmsa(vm)

using FastaIO
vm = FastaIO.readfasta("data/fasta1.fas") |> Node
fig1 = viewmsa(vm)
```

![pf00062x](https://user-images.githubusercontent.com/26263436/141277817-16a4958d-6637-43b0-9946-1916c2947c3a.png)

Open an issue or a pull request on github,

or join the chat on Slack:
https://julialang.slack.com

or Zulip:
https://julialang.zulipchat.com 

or Julialang Discourse (specifically the *Visualization* and *Biology, Health and Medicine* domains):
https://discourse.julialang.org/
