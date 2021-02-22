# # Proteins

# ## Structures

# You can load a Protein Structure from the PDB (Protein Data Bank) using its ID like so:
pstruc1 = viewstruc("2VB1")

# ## Multiple sequence alignments

# You can similarly load a Multiple Sequence Alignment from the Pfam database using its
# ID like so:
msa1 = viewmsa("PF00062"; sheetsize = [20,10], resolution = (800,400))
