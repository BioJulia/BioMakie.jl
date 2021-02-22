# # Proteins

# ## Structures

# You can load a Protein Structure from the PDB (Protein Data Bank):
pstruc1 = viewstruc("2VB1")

# ## Multiple sequence alignments

# You can similarly load a Multiple Sequence Alignment from the Pfam database:
msa1 = viewmsa("PF00062")

#md # ![](msa1.svg)
#md # ![Image of msa](pf00062.png)
# An `MSAView` contains the most relevant information about the protein sequences in the
# alignment along with the `Scene` and `Layout` which comprise the interface.

# using Literate #src
# Literate.markdown("src/proteins.jl","src") #src
