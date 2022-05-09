var documenterSearchIndex = {"docs":
[{"location":"#BioMakie.jl","page":"Home","title":"BioMakie.jl","text":"","category":"section"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Julia is required. This package is being developed with Julia 1.7, so some features may not work if an earlier version is used. Install the BioMakie master branch from the Julia REPL. Enter the package mode by pressing ] and run:","category":"page"},{"location":"","page":"Home","title":"Home","text":"add BioMakie.","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"#Structure","page":"Home","title":"Structure","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"There are different representations for protein structures, including \"ball and stick\" (:ballandstick), \"covalent\" (:covalent), and \"space filling\" (:spacefilling). The default Makie backend is GLMakie.jl. So far, plotting methods exist specifically for dealing with BioStructures objects like ProteinStructure and Chain.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The main plotting functions are plotstruc and plotmsa, along with their mutating versions, plotstruc! and plotmsa!. The mutating functions allow the user to add multiple plots to the same Figure, using grid positions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using GLMakie # hide\nGLMakie.activate!() # hide\nset_theme!(resolution=(800, 400)) # hide\nusing GLMakie: lift, @lift, Observable # hide\nusing BioMakie\nusing BioStructures\nstruc = retrievepdb(\"2vb1\"; dir = \"assets/\") |> Observable\n# or\nstruc = read(\"assets/2vb1.pdb\", BioStructures.PDB) |> Observable","category":"page"},{"location":"","page":"Home","title":"Home","text":"fig = Figure()\nplotstruc!(fig, struc; plottype = :spacefilling, gridposition = (1,1), atomcolors = aquacolors)\nplotstruc!(fig, struc; plottype = :covalent, gridposition = (1,2))\nnothing # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: strucs)","category":"page"},{"location":"#Multiple-Sequence-Alignments","page":"Home","title":"Multiple Sequence Alignments","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Multiple Sequence Alignments (MSAs) are plotted using a matrix of residue letters, and a matrix of values for the heatmap colors. If only a matrix of letters is provided as input, colors will be automatic. MSA objects from MIToS have specific support, as well as Fasta files loaded with FastaIO.jl or [FASTX.jl].","category":"page"},{"location":"","page":"Home","title":"Home","text":"To view a multiple sequence alignment, use the plotmsa or plotmsa! function with a Pfam MSA or fasta file.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using MIToS # hide\nusing MIToS.MSA\nmsa = MIToS.MSA.read(\"assets/pf00062.stockholm.gz\",Stockholm) |> Observable\n# or\nusing FASTX\nreader = open(FASTX.FASTA.Reader, \"assets/PF00062_full.fasta\")\nmsa = [record for record in reader]\nclose(reader)\n\nmsamatrix, xlabel, ylabel = getplottingdata(msa) .|> Observable\nmsafig, plotdata... = plotmsa(msamatrix;\n\t\t\t\txlabels = xlabel,\n\t\t\t\tylabels = ylabel, colorscheme = :buda)\nnothing # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: MSA)","category":"page"},{"location":"#Additional-examples","page":"Home","title":"Additional examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Multiple sequence alignments can be connected to corresponding protein structures, so columns selected in the MSA will be selected on the protein structure, if the structure has a residue for that position.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: MSA-struc connect)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Animation of a mesh through different trajectories:","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: shape animate)","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"This page was generated using Literate.jl.","category":"page"},{"location":"API/#BioMakie-API","page":"API","title":"BioMakie API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"","category":"page"},{"location":"API/","page":"API","title":"API","text":"Modules = [BioMakie]","category":"page"},{"location":"API/#BioMakie.atomcoords-Tuple{Any}","page":"API","title":"BioMakie.atomcoords","text":"atomcoords(atoms)\n\nConvenience function for collecting atom coordinates for plotting.\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.atomradii-Tuple{Any}","page":"API","title":"BioMakie.atomradii","text":"atomradii(atoms)\n\nCollect atom radii for plotting. Uses BioStructures to get radii based on atomic element.\n\nOptional Arguments:\n\nradiustype –- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.getplottingdata-Tuple{Any}","page":"API","title":"BioMakie.getplottingdata","text":"getplottingdata( msa )::Tuple{Matrix{String}, Vector{String}, Vector{String}}\n\nCollects data for plotting (residue string matrix, x labels, and y labels).\n\nThis function converts an AbstractMultipleSequenceAlignment (from MIToS.MSA), or  a Vector{Tuple{String,String}} (from FastaIO), or a Vector{FASTX.FASTA.Record}  to a matrix of residue characters, x labels, and y labels.\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.msavalues","page":"API","title":"BioMakie.msavalues","text":"msavalues( msa::AbstractMatrix, resdict::AbstractDict )::Matrix{Real}\n\nReturns a matrix of numbers according to the given dictionary, where keys are residue letters and values are numbers. This matrix is used as input for plotmsa for the heatmap colors.\n\nDefault values for residue letters are from Kidera Factor values.  kf 2 is Kidera Factor 2 (size/volume-related). The KF dictionary is in utils.jl.\n\n\n\n\n\n","category":"function"},{"location":"API/#BioMakie.plotmsa!-Tuple{Figure, Observable, Observable}","page":"API","title":"BioMakie.plotmsa!","text":"plotmsa!( fig, msa, msavalues )\n\nPlot a multiple sequence alignment (MSA) into a Figure. \n\nExamples\n\nfig = Figure(resolution = (1100, 400))\n\nplotmsa!( fig::Figure, msamatrix::Matrix{String}, matrixvals::Matrix{Float32};\n\t\txlabels = xlabels1, \t\n\t\tylabels = ylabels1,\n\t\tkwargs... )\n\nOptional Arguments:\n\nxlabels –––- {1:height}\nylabels –––- {1:width}\nsheetsize ––- [40,20]\ngridposition – (1,1)\ncolorscheme –- :viridis\nmarkersize –– (11.0,11.0)\nmarkercolor –- :black\nkwargs...   \t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotmsa-Tuple{Any, Any}","page":"API","title":"BioMakie.plotmsa","text":"plotmsa( msa, msavalues )\n\nPlot a multiple sequence alignment (MSA). Returns a Figure, or a Figure and Observables for interaction.\n\nExamples\n\nplotmsa( msamatrix::Matrix{String}, \n\t\t matrixvals::Matrix{Float32};\n\t\t xlabels = xlabel::Vector{String}, \t\n\t\t ylabels = ylabel::Vector{String}, \n\t\t kwargs... )\n\nOptional Arguments:\n\nxlabels –––––- {1:height}\nylabels –––––- {1:width}\nresolution –––– (1100, 400)\nsheetsize ––––- [40,20]\ngridposition ––– (1,1)\ncolorscheme –––- :viridis\nreturnobservables - true          # Return Observables for interaction.\nkwargs...    \t\t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotmsa-Tuple{Any}","page":"API","title":"BioMakie.plotmsa","text":"plotmsa( msa )\n\nPlot a multiple sequence alignment (MSA). Returns a Figure, or a Figure and Observables for interaction. \n\nExamples\n\nplotmsa( msamatrix::Matrix{String};\n         xlabels = xlabel::Vector{String}, \t\n         ylabels = ylabel::Vector{String}, \n         kwargs... )\n\nOptional Arguments:\n\nxlabels –––––- {1:height}\nylabels –––––- {1:width}\nresolution –––– (1100, 400)\nsheetsize ––––- [40,20]\ngridposition ––– (1,1)\ncolorscheme –––- :viridis\nresdict –––––- kideradict    # Dictionary of values (::Dict{String,Float}, \"Y\" => 1.48) for heatmap.\nkf –––––––– 2             # If resdict == kideradict, this is the Kidera Factor. KF2 is size/volume-related.\nreturnobservables - true          # Return Observables for interaction.\nkwargs...    \t\t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotstruc!-Tuple{Figure, Observable}","page":"API","title":"BioMakie.plotstruc!","text":"plotstruc!( fig, structure )\n\nPlot a protein structure into a Figure. Position can be specified with the  gridposition keyword argument.\n\nExamples\n\nfig = Figure()\nusing BioStructures\nstruc = retrievepdb(\"2vb1\", dir = \"data/\") |> Observable\nsv = plotstruc!(fig, struc)\n\nstruc = read(\"data/2vb1_mutant1.pdb\", BioStructures.PDB) |> Observable\nsv = plotstruc!(fig, struc)\n\nOptional Arguments:\n\nselectors ––- [standardselector]\nresolution –– (800,800)\ngridposition – (1,1)\nplottype ––– :ballandstick, another option is :spacefilling\natomcolors –– elecolors, another option is aquacolors, or define your own dict for atoms like: \"N\" => :blue\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotstruc-Tuple{Any}","page":"API","title":"BioMakie.plotstruc","text":"plotstruc(structure)\n\nCreate and return a Makie Figure for a protein structure,  along with the structure wrapped in an Observable if it wasn't Observable already. \n\nExamples\n\nusing BioStructures\nstruc = retrievepdb(\"2vb1\", dir = \"data/\") |> Observable\nsv = plotstruc(struc)\n\nstruc = read(\"data/2vb1_mutant1.pdb\", BioStructures.PDB) |> Observable\nsv = plotstruc(struc)\n\nOptional Arguments:\n\nselectors ––- [standardselector]\nresolution –– (800,800)\ngridposition – (1,1)\nplottype ––– :ballandstick, another option is :spacefilling\natomcolors –– elecolors, another option is aquacolors, or define your own dict for atoms like: \"N\" => :blue\n\n\n\n\n\n","category":"method"}]
}
