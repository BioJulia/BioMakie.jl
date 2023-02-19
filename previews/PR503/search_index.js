var documenterSearchIndex = {"docs":
[{"location":"#BioMakie.jl","page":"Home","title":"BioMakie.jl","text":"","category":"section"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Julia is required. This package is being developed with Julia 1.7, so some features may not work if an earlier version is used. Install the BioMakie master branch from the Julia REPL. Enter the package mode by pressing ] and run:","category":"page"},{"location":"","page":"Home","title":"Home","text":"add BioMakie.","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"#Structure","page":"Home","title":"Structure","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"There are different representations for protein structures, including \"ball and stick\" (:ballandstick), \"covalent\" (:covalent), and \"space filling\" (:spacefilling). The default Makie backend is GLMakie.jl. So far, plotting methods exist specifically for dealing with BioStructures objects like ProteinStructure and Chain.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The main plotting functions are plotstruc and plotmsa, along with their mutating versions, plotstruc! and plotmsa!. The mutating functions allow the user to add multiple plots to the same Figure, using grid positions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using BioMakie\nusing BioStructures\nstruc = retrievepdb(\"2vb1\"; dir = \"assets/\") |> Observable\n# or\nstruc = read(\"assets/2vb1.pdb\", BioStructures.PDB) |> Observable","category":"page"},{"location":"","page":"Home","title":"Home","text":"fig = Figure()\nplotstruc!(fig, struc; plottype = :spacefilling, gridposition = (1,1), atomcolors = aquacolors)\nplotstruc!(fig, struc; plottype = :covalent, gridposition = (1,2))","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: strucs)","category":"page"},{"location":"#Multiple-Sequence-Alignments","page":"Home","title":"Multiple Sequence Alignments","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Multiple Sequence Alignments (MSAs) are plotted using a matrix of residue letters, and a matrix of values for the heatmap colors. If only a matrix of letters is provided as input, colors will be automatic. MSA objects from MIToS have specific support, as well as Fasta files loaded with FastaIO.jl or [FASTX.jl].","category":"page"},{"location":"","page":"Home","title":"Home","text":"To view a multiple sequence alignment, use the plotmsa or plotmsa! function with a Pfam MSA or fasta file.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using FASTX\nreader = open(FASTX.FASTA.Reader, \"assets/PF00062_full.fasta\")\nmsa = [reader...] |> Observable\nclose(reader)\n## or \nusing MIToS # hide\nusing MIToS.MSA\nmsa = MIToS.MSA.read(\"assets/pf00062.stockholm.gz\",Stockholm) |> Observable\n\nmsamatrix, xlabel, ylabel = getplottingdata(msa) .|> Observable\nmsafig, plotdata... = plotmsa(msamatrix;\n\t\t\t\txlabels = xlabel,\n\t\t\t\tylabels = ylabel, colorscheme = :tableau_blue_green)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: MSA)","category":"page"},{"location":"#Additional-examples","page":"Home","title":"Additional examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Multiple sequence alignments can be connected to corresponding protein structures, so columns selected in the MSA will be selected on the protein structure, if the structure has a residue for that position.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: MSA-struc connect)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Animation of a mesh through different trajectories:","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: shape animate)","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"This page was generated using Literate.jl.","category":"page"},{"location":"API/#BioMakie-API","page":"API","title":"BioMakie API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"","category":"page"},{"location":"API/","page":"API","title":"API","text":"Modules = [BioMakie]","category":"page"},{"location":"API/#BioMakie.atomcolors-Tuple{BioStructures.StructuralElementOrList}","page":"API","title":"BioMakie.atomcolors","text":"atomcolors( atoms )\n\nGet a Vector of colors for the atoms. To see all default element and amino acid colorschemes, use getbiocolors(). Keyword argument colors takes a Dict which maps element to color. (\"C\" => :red)\n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nKeyword Arguments:\n\ncolors –- elecolors | Options - elecolors, aquacolors\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.atomradii-Union{Tuple{Vector{T}}, Tuple{T}} where T<:BioStructures.AbstractAtom","page":"API","title":"BioMakie.atomradii","text":"atomradii( atoms )\n\nCollect atom radii based on element for plotting.\n\nKeyword Arguments:\n\nradiustype –- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.atomradius-Tuple{T} where T<:BioStructures.AbstractAtom","page":"API","title":"BioMakie.atomradius","text":"atomradius( atom )\n\nCollect atom radius based on element for plotting.\n\nKeyword Arguments:\n\nradiustype –- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.atomsizes-Tuple{BioStructures.StructuralElementOrList}","page":"API","title":"BioMakie.atomsizes","text":"atomsizes( atms )\n\nGet a Vector of sizes for the atoms from a BioStructures.StructuralElementOrList.\n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nKeyword Arguments:\n\nradiustype –- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.backbonebonds-Tuple{BioStructures.Chain}","page":"API","title":"BioMakie.backbonebonds","text":"backbonebonds( chn::BioStructures.Chain ) -> BitMatrix\n\nReturns a matrix of backbone bonds in chn, where Mat[i,j] = 1 if atoms i and j are bonded. \n\nKeyword Arguments:\n\ncutoff –––––- 1.6\t\t# distance cutoff for bonds\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.bondshape-Union{Tuple{Tuple{T}}, Tuple{T}} where T<:BioStructures.AbstractAtom","page":"API","title":"BioMakie.bondshape","text":"bondshape( twoatoms )\nbondshape( twopoints )\n\nReturns a (mesh) cylinder between two atoms or atomic coordinates.\n\nKeyword Arguments:\n\nbondwidth ––––––- 0.2\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.bondshapes-Tuple{BioStructures.Chain}","page":"API","title":"BioMakie.bondshapes","text":"bondshapes( structure )\nbondshapes( residues )\nbondshapes( structure, bondmatrix )\nbondshapes( residues, bondmatrix )\n\nReturns a (mesh) cylinder between two atoms or points.\n\nKeyword Arguments:\n\nalgo ––––––––– :knowledgebased | :distance, :covalent\t# unless bondmatrix is given\ndistance ––––––– 1.9\t\t\t\t\t\t\t\t\t\t# unless bondmatrix is given\nbondwidth ––––––- 0.2\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.covalentbonds-Union{Tuple{Vector{T}}, Tuple{T}} where T<:BioStructures.AbstractAtom","page":"API","title":"BioMakie.covalentbonds","text":"covalentbonds( atms ) -> BitMatrix\n\nReturns a matrix of all bonds in atms, where Mat[i,j] = 1 if atoms i and j are bonded. \n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nKeyword Arguments:\n\nextradistance –– 0.14  # fudge factor for better inclusion\nH –––––––– true  # include bonds with hydrogen atoms\ndisulfides –––- false # include disulfide bonds\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.distancebonds-Union{Tuple{Vector{T}}, Tuple{T}} where T<:BioStructures.AbstractAtom","page":"API","title":"BioMakie.distancebonds","text":"distancebonds( atms ) -> BitMatrix\n\nReturns a matrix of all bonds in atms, where Mat[i,j] = 1 if atoms i and j are bonded. \n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nKeyword Arguments:\n\ncutoff –––––- 1.9   # distance cutoff for bonds between heavy atoms\nhydrogencutoff –- 1.14  # distance cutoff for bonds with hydrogen atoms\nH –––––––– true  # include bonds with hydrogen atoms\ndisulfides –––- false # include disulfide bonds\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.firstlabel-Tuple{Function}","page":"API","title":"BioMakie.firstlabel","text":"firstlabel( inspectorfunc::Function )\nfirstlabel( inspectorfunc::Observable{T} ) where {T<:Function}\n\nShow an example of the inspector label function looks like. The position p will not be available to this function, so it will be set to nothing.\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.getbonds-Tuple{BioStructures.Chain, Vararg{Any}}","page":"API","title":"BioMakie.getbonds","text":"getbonds( chn::BioStructures.Chain, selectors... ) -> BitMatrix\n\nReturns a matrix of all bonds in chn, where Mat[i,j] = 1 if atoms i and j are bonded. \n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nKeyword Arguments:\n\nalgo ––––––- :knowledgebased \t# (:distance, :covalent) algorithm to find bonds\nH –––––––– true\t\t\t\t# include bonds with hydrogen atoms\ncutoff –––––- 1.9\t\t\t\t# distance cutoff for bonds between heavy atoms\nextradistance –– 0.14\t\t\t\t# fudge factor for better inclusion\ndisulfides –––- false\t\t\t\t# include disulfide bonds\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.getbonds-Tuple{Vector{MIToS.PDB.PDBResidue}}","page":"API","title":"BioMakie.getbonds","text":"getbonds( residues ) -> BitMatrix\n\nReturns a matrix of all bonds in residues, where Mat[i,j] = 1 if atoms i and j are bonded.\n\nKeyword Arguments:\n\nalgo ––––––- :knowledgebased \t# (:distance, :covalent) algorithm to find bonds\nH –––––––– true\t\t\t\t# include bonds with hydrogen atoms\ncutoff –––––- 1.9\t\t\t\t# distance cutoff for bonds between heavy atoms\nextradistance –– 0.14\t\t\t\t# fudge factor for better inclusion\ndisulfides –––- false\t\t\t\t# include disulfide bonds\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.getinspectorlabel-Tuple{BioStructures.StructuralElementOrList}","page":"API","title":"BioMakie.getinspectorlabel","text":"getinspectorlabel( structure )\ngetinspectorlabel( residues )\ngetinspectorlabel( atom )\n\nGet the inspector label function for plotting a 'StructuralElementOrList'.\n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.msavalues","page":"API","title":"BioMakie.msavalues","text":"msavalues( msa::AbstractMatrix, resdict::AbstractDict )::Matrix{Real}\n\nReturns a matrix of numbers according to the given dictionary, where keys are residue letters and values are numbers. This matrix is used as input for plotmsa for the heatmap colors.\n\nDefault values for residue letters are from Kidera Factor values.  kf 2 is Kidera Factor 2 (size/volume-related). The KF dictionary is in utils.jl.\n\n\n\n\n\n","category":"function"},{"location":"API/#BioMakie.plotmsa!","page":"API","title":"BioMakie.plotmsa!","text":"plotmsa!( fig, msa, msavalues, xlabels, ylabels )\n\nPlot a multiple sequence alignment (MSA) into a Figure. \n\nExample\n\nfig = Figure(resolution = (1100, 400))\n\nplotmsa!( fig::Figure, msamatrix::Matrix{String}, matrixvals::Matrix{Float32},\n\t\t\txlabels::Vector{String}, \t\n\t\t\tylabels::Vector{String};\n\t\t\tkwargs... )\n\nKeyword Arguments:\n\nxlabels –––- {1:height}\nylabels –––- {1:width}\nsheetsize ––- [40,20]\ngridposition – (1,1)\nmarkersize –– 12\ncolorscheme –- :buda\nmarkercolor –- :black\nkwargs...   \t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"function"},{"location":"API/#BioMakie.plotmsa!-NTuple{4, Any}","page":"API","title":"BioMakie.plotmsa!","text":"plotmsa!( msamatrix, matrixvals, xlabels, ylabels )\n\nPlot a multiple sequence alignment (MSA) into a Figure. \n\nExample\n\nplotmsa!( msamatrix::Matrix{String}, matrixvals::Matrix{Float32},\n\t\t\txlabels::Vector{String}, \t\n\t\t\tylabels::Vector{String};\n\t\t\tkwargs... )\n\nKeyword Arguments:\n\nxlabels –––- {1:height}\nylabels –––- {1:width}\nsheetsize ––- [40,20]\ngridposition – (1,1)\nmarkersize –– 12\ncolorscheme –- :buda\nmarkercolor –- :black\nkwargs...   \t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotmsa!-NTuple{5, Any}","page":"API","title":"BioMakie.plotmsa!","text":"plotmsa!( fig, msamatrix, matrixvals, xlabels, ylabels )\n\nPlot a multiple sequence alignment (MSA) into a Figure. \n\nExample\n\nfig = Figure(resolution = (1100, 400))\n\nplotmsa!( fig::Figure, msamatrix::Matrix{String}, matrixvals::Matrix{Float32},\n\t\t\txlabels::Vector{String}, \t\n\t\t\tylabels::Vector{String};\n\t\t\tkwargs... )\n\nKeyword Arguments:\n\nxlabels –––- {1:height}\nylabels –––- {1:width}\nsheetsize ––- [40,20]\ngridposition – (1,1)\nmarkersize –– 12\ncolorscheme –- :buda\nmarkercolor –- :black\nkwargs...   \t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotmsa-NTuple{4, Any}","page":"API","title":"BioMakie.plotmsa","text":"plotmsa( fig, msamatrix, msavalues, xlabels, ylabels )\n\nPlot a multiple sequence alignment (MSA) on a Figure. \n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotmsa-Tuple{Any, Any}","page":"API","title":"BioMakie.plotmsa","text":"plotmsa( msa, msavalues )\n\nPlot a multiple sequence alignment (MSA). Returns a Figure, or a Figure and Observables for interaction.\n\nExamples\n\nusing MIToS.MSA\ndownloadpfam(\"PF00062\")\nmsa = MIToS.MSA.read(\"PF00062.stockholm.gz\", Stockholm, \n\t\t\t\t\tgeneratemapping =true, useidcoordinates=true)\nmsamatrix, xlabels, ylabels = plottingdata(msa) .|> Observable\t\t\t\nmatrixvals = msavalues(msamatrix[]) |> Observable\n\nplotmsa( msa, matrixvals; kwargs... )\n\nKeyword Arguments:\n\nresolution –––– (1100, 400)\nsheetsize ––––- [40,20]\ngridposition ––– (1,1)\ncolorscheme –––- :viridis\nkwargs...    \t\t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotmsa-Tuple{Any}","page":"API","title":"BioMakie.plotmsa","text":"plotmsa( msa )\n\nPlot a multiple sequence alignment (MSA). Returns a Figure, or a Figure and Observables for interaction. \n\nExamples\n\ndownloadpfam(\"PF00062\")\nmsa = MIToS.MSA.read(\"PF00062.stockholm.gz\", Stockholm, \n\t\t\t\t\tgeneratemapping =true, useidcoordinates=true)\n\nplotmsa( msa; kwargs... )\n\nKeyword Arguments:\n\nresolution –––– (1100, 400)\nsheetsize ––––- [40,20]\ngridposition ––– (1,1)\ncolorscheme –––- :viridis\nresdict –––––- kideradict    # Dictionary of values (::Dict{String,Float}, \"Y\" => 1.48) for heatmap.\nkf –––––––– 2             # If resdict == kideradict, this is the Kidera Factor. KF2 is size/volume-related.\nkwargs...    \t\t\t\t\t\t# forwarded to scatter plot\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotstruc!-Tuple{Any, Any}","page":"API","title":"BioMakie.plotstruc!","text":"plotstruc!( fig, structure )\n\nPlot a protein structure(/chain/residues/atoms) into a Figure. \n\nExamples\n\nfig = Figure()\n\nusing MIToS.PDB\n\npdbfile = MIToS.PDB.downloadpdb(\"2vb1\")\nstruc = MIToS.PDB.read(pdbfile, PDBML) |> Observable\nstrucplot = plotstruc!(fig, struc)\n\nchain_A = @residues struc model \"1\" chain \"A\" group \"ATOM\" residue All\nstrucplot = plotstruc!(fig, chain_A)\n\nchnatms = @atoms struc model \"1\" chain \"A\" group \"ATOM\" residue All atom All\nstrucplot = plotstruc!(fig, chnatms)\n-------------------------\nusing BioStructures\n\nstruc = retrievepdb(\"2vb1\", dir = \"data/\") |> Observable\nstrucplot = plotstruc!(fig, struc)\n\nstruc = read(\"data/2vb1_mutant1.pdb\", BioStructures.PDB) |> Observable\nstrucplot = plotstruc!(fig, struc)\n\nchain_A = retrievepdb(\"2hhb\", dir = \"data/\")[\"A\"] |> Observable\nstrucplot = plotstruc!(fig, chain_A)\n\nKeyword Arguments:\n\nresolution ––- (800,600)\ngridposition –- (1,1)  # if an MSA is already plotted, (2,1:3) works well\nplottype –––- :covalent, :ballandstick, or :spacefilling\natomcolors ––- elecolors, others in getbiocolors(), or provide a Dict like: \"N\" => :blue\nmarkersize ––- 0.0\nmarkerscale –– 1.0\nbondtype –––- :knowledgebased, :covalent, or :distance\ndistance –––- 1.9  # distance cutoff for covalent bonds\ninspectorlabel - :default, or define your own function like: (self, i, p) -> \"atom: ... coords: ...\"\nkwargs... ––– keyword arguments passed to the atom meshscatter\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plotstruc-Tuple{Any}","page":"API","title":"BioMakie.plotstruc","text":"plotstruc( structure )\nplotstruc( plotdata )\n\nCreate and return a Makie Figure for a protein structural element. \n\nExamples\n\nusing MIToS.PDB\n\npdbfile = MIToS.PDB.downloadpdb(\"2vb1\")\nstruc = MIToS.PDB.read(pdbfile, PDBML) |> Observable\nstrucplot = plotstruc(struc)\n\nchain_A = @residues struc model \"1\" chain \"A\" group \"ATOM\" residue All\nstrucplot = plotstruc(chain_A)\n\nchnatms = @atoms struc model \"1\" chain \"A\" group \"ATOM\" residue All atom All\nstrucplot = plotstruc(chnatms)\n-------------------------\nusing BioStructures\n\nstruc = retrievepdb(\"2vb1\", dir = \"data/\") |> Observable\nstrucplot = plotstruc(struc)\n\nstruc = read(\"data/2vb1_mutant1.pdb\", BioStructures.PDB) |> Observable\nstrucplot = plotstruc(struc)\n\nchain_A = retrievepdb(\"2hhb\", dir = \"data/\")[\"A\"] |> Observable\nstrucplot = plotstruc(chain_A)\n\nKeyword Arguments:\n\nresolution ––- (800,600)\ngridposition –- (1,1)  # if an MSA is already plotted, (2,1:3) works well\nplottype –––- :covalent, :ballandstick, or :spacefilling\natomcolors ––- elecolors, others in getbiocolors(), or provide a Dict like: \"N\" => :blue\nmarkersize ––- 0.0\nmarkerscale –– 1.0\nbondtype –––- :knowledgebased, :covalent, or :distance\ndistance –––- 1.9  # distance cutoff for covalent bonds\ninspectorlabel - :default, or define your own function like: (self, i, p) -> \"atom: ... coords: ...\"\nkwargs... ––– keyword arguments passed to the atom meshscatter\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plottingdata-Tuple{BioStructures.StructuralElementOrList}","page":"API","title":"BioMakie.plottingdata","text":"plottingdata( structure )\nplottingdata( residues )\nplottingdata( atoms )\n\nThis function returns an OrderedDict of the main data used for plotting. \n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nReturns:\n\nOrderedDict(\"atoms\" => ..., \n            \"coords\" => ..., \n            \"colors\" => ...,\n            \"sizes\" => ...,\n            \"bonds\" => ...)\n\nKeyword Arguments:\n\ncolors –––- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors\nradiustype –- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.plottingdata-Tuple{MIToS.MSA.AbstractMultipleSequenceAlignment}","page":"API","title":"BioMakie.plottingdata","text":"plottingdata( msa )\n\nCollects data for plotting (residue string matrix, x labels, and y labels) from a multiple sequence alignment (MSA) object. \n\nThe MSA object can be a: \n\nAbstractMultipleSequenceAlignment from MIToS.MSA, \nvector of tuples 'Vector{Tuple{String,String}}' from FastaIO, \nvector of FASTA records 'Vector{FASTX.FASTA.Record}' from FASTX.\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.rescolors-Tuple{BioStructures.StructuralElementOrList}","page":"API","title":"BioMakie.rescolors","text":"rescolors( residues )\n\nGet a Vector of colors for the atoms. To see all default element and amino acid colorschemes, use getbiocolors(). Keyword argument colors takes a Dict which maps residue to color. (\"C\" => :red)\n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nKeyword Arguments:\n\ncolors –- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors\n\n\n\n\n\n","category":"method"},{"location":"API/#BioMakie.sidechainbonds-Tuple{BioStructures.AbstractResidue, Vararg{Any}}","page":"API","title":"BioMakie.sidechainbonds","text":"sidechainbonds( res::BioStructures.AbstractResidue, selectors... ) -> BitMatrix\n\nReturns a matrix of sidechain bonds in res, where Mat[i,j] = 1 if atoms i and j are bonded.\n\nThis function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.\n\nKeyword Arguments:\n\nalgo ––––––- :knowledgebased \t# (:distance, :covalent) algorithm to find bonds\nH –––––––– true\t\t\t\t# include bonds with hydrogen atoms\ncutoff –––––- 1.9\t\t\t\t# distance cutoff for bonds between heavy atoms\nextradistance –– 0.14\t\t\t\t# fudge factor for better inclusion\n\n\n\n\n\n","category":"method"}]
}
