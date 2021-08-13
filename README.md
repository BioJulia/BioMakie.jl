# BioMakie

BioMakie is still in what what I would consider its early stages, and there is still a lot of work to do. 
If you have any ideas or code, I'd love to collaborate! 

Open an issue or a pull request on github, 

or join the chat on Slack:    
https://join.slack.com/t/julialang/shared_invite/zt-nmal0i0x-LcYEtdnTameGsXmBzMzgog - "invite link"   
https://julialang.slack.com - regular link

or Zulip:   
https://julialang.zulipchat.com 

or Julialang Discourse (specifically the *Visualization* and *Biology, Health and Medicine* domains):   
https://discourse.julialang.org/

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
<p align="center">
  <img width="550" height="620" src="docs/src/assets/2vb1.png">
</p>


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
![Image of msa](docs/src/assets/pf00062.png)


Here is a downloader for data from PDBe. Call it with `PDBe_downloader(pdbid)`.
```julia
fig = PDBe_downloader("2vb1")

pdbid = "2vb1" |> Node
fig = PDBe_downloader(pdbid)
```
<p align="center">
  <img width="450" height="620" src="docs/src/assets/dler.png">
</p>
