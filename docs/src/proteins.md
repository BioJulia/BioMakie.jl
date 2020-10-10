# Proteins

## Structures

You can load a Protein Structure from the PDB (Protein Data Bank) using its ID like so:
```julia
julia> pstruc1 = viewstruc("2VB1")  # opens a 'Scene' and returns a 'StructureView'
```
A `StructureView` is an object that contains the relevant information about the
protein along with the `Scene` and `Layout` which describe the interface.

You could also look at multiple structures at once.
```julia
julia> svs = viewstrucs(["2vb1","1lw3"], colors = ["aqua","ele"])
```
![Image of strucs](https://github.com/kool7d/BioMakie.jl/blob/master/assets/2strucs.png)

## Multiple sequence alignments

You can similarly load a Multiple Sequence Alignment from the Pfam database using its
ID like so:
```julia
julia> msa1 = viewmsa("PF00062")  # opens a 'Scene' and returns an 'MSAView'
```
An `MSAView` contains the relevant information about the protein sequences in the
alignment along with the `Scene` and `Layout` which specify the interface.
