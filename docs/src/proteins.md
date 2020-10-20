```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/master/src/proteins.jl"
```

# Proteins

## Structures

You can load a Protein Structure from the PDB (Protein Data Bank) using its ID like so:

```@example proteins
pstruc1 = viewstruc("2VB1")  # opens a 'Scene' and returns a 'StructureView'
```

A `StructureView` is an object that contains the relevant information about the
protein along with the `Scene` and `Layout` which describe the interface.

You could also look at multiple structures at once.

```@example proteins
svs = viewstrucs(["2vb1","1lw3"], colors = ["aqua","ele"])
```
![Image of 2strucs](https://github.com/kool7d/BioMakie.jl/tree/master/docs/assets/2strucs.png)
![Image of 2strucs2](https://raw.githubusercontent.com/kool7d/BioMakie.jl/master/docs/assets/2vb1.png)


## Multiple sequence alignments

You can similarly load a Multiple Sequence Alignment from the Pfam database using its
ID like so:

```@example proteins
msa1 = viewmsa("PF00062")  # opens a 'Scene' and returns an 'MSAView'
```
![Image of msa](BioMakie.jl/docs/assets/pf00062.png)

An `MSAView` contains the most relevant information about the protein sequences in the
alignment along with the `Scene` and `Layout` which comprise the interface.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

