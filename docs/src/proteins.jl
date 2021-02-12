# # Proteins

# ## Structures

# You can load a Protein Structure from the PDB (Protein Data Bank) using its ID like so:
pstruc1 = viewstruc("2VB1")

# You could also look at multiple structures at once.
svs = viewstrucs(["2vb1","1lw3"], colors = ["aqua","ele"])
#md # ![](https://github.com/kool7d/BioMakie.jl/blob/master/assets/2vb1.png)
#md # [![](https://github.com/kool7d/BioMakie.jl/blob/master/assets/2vb1.png)]
svs.scene[1]
# ## Multiple sequence alignments

# You can similarly load a Multiple Sequence Alignment from the Pfam database using its
# ID like so:
msa1 = viewmsa("PF00062")

#md # ![](msa1.svg)
#md # ![Image of msa](pf00062.png)

# using Literate #src
# Literate.markdown("src/proteins.jl","src") #src
