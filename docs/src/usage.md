```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/master/docs/src/GLusage.jl"
```

## Usage

To view a PDB structure, use the `viewstruc` function with a PDB ID or BioStructures protein structure.
```julia
sv = viewstruc("2VB1")

struc = retrievepdb("2vb1", dir = "data\\")
sv = viewstruc(struc)

struc = read("data\\2vb1_m1.pdb", BioStructures.PDB)
sv = viewstruc(struc)
```
<p align="center">
  <img width="650" height="720" src="./assets/2vb1.png">
</p>

To view a multiple sequence alignment, use the `viewmsa` function with a Pfam ID or fasta file.
```julia
mv = viewmsa("PF00062")
```
```julia
mv = viewmsa("data/fasta1.fas")
```
![Image of msa](./assets/pf00062.png)

```@example 1
using JSServe
Page(exportable=true, offline=true)
```

```@example 1
using WGLMakie
WGLMakie.activate!()

fig = Figure()

lscene = LScene(fig[1, 1], scenekw = (camera = cam3d!, raw = false))

# now you can plot into lscene like you're used to
meshscatter!(lscene, randn(100, 3))
fig
```