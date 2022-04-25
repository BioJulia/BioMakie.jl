# # Overview

# The main plotting functions are **plotstruc** and **plotmsa**, along with their mutating 
# versions, **plotstruc!** and **plotmsa!**. More plots will be added in the future, such as 
# phylogenetic trees. The mutating functions allow the user to add multiple plots to the same 
# Figure, using grid positions.

# ## Structures

# There are different representations for protein structures, including "ball and stick"
# (**:ballandstick**), "covalent" (**:covalent**), and "space filling" (**:spacefilling**). The default
# Makie backend is GLMakie.jl, but support for others is in progress, along with methods for 
# connecting Makie representations to external graphical software like [MolStar](https://github.com/molstar/molstar). 

# Protein structures are plotted using coordinates, radii, colors, and bonds (for "ballandstick"). 
# So far, plotting methods exist specifically for dealing with BioStructures objects like 
# ProteinStructure and Chain. Other packages with specific support include [MIToS.jl](https://diegozea.github.io/MIToS.jl) 
# and [MolecularGraph.jl](https://mojaie.github.io/MolecularGraph.jl). Support for additional
# packages will added over time. 

#![structure examples](assets/vdwcov.png)

# ## Multiple Sequence Alignments

# Multiple Sequence Alignments (MSAs) are plotted using a matrix of residue letters, and a
# matrix of values for the heatmap colors. If only a matrix of letters is provided as input,
# colors will be automatic. MSA objects from MIToS have specific support, as well as Fasta files
# loaded with FastaIO.jl or [FASTX.jl].

#![MSA example](assets/msa.png)

# ## MSA + Structure

# Multiple sequence alignments can be connected to corresponding protein structures, so columns 
# selected in the MSA will be selected on the protein structure, if the structure has a residue
# for that position. 

#![MSA-struc connect](assets/selectres.png)