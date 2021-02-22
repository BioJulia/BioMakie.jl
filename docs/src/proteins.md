```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/master/src/proteins.jl"
```

# Proteins

## Structures

You can load a Protein Structure from the PDB (Protein Data Bank) using its ID like so:

```@example proteins
pstruc1 = viewstruc("2VB1")
```

## Multiple sequence alignments

You can similarly load a Multiple Sequence Alignment from the Pfam database using its
ID like so:

```@example proteins
msa1 = viewmsa("PF00062")
```


---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
