atomcoords(atoms) = coordarray(atoms) |> transpose |> collect
atomcolors(atoms; color = elecolors) = [color[BioStructures.element(x)] for x in atoms]
atomradii(atoms) = [vdwrad[BioStructures.element(x)] for x in atoms]
resids(residues) = resid.(residues)
function resatoms(res; typ = :OrderedDict)
	resvec1 = [k for k in res]
	if typ in (:OrderedDict, :ordereddict, :odict, OrderedDict)
		resvec2 = [(resvec1[i].name, coords(resvec1[i])) for i in 1:size(resvec1,1)]
		return OrderedDict(resvec2)
	else
		return [[resvec1[i].name, coords(resvec1[i])] for i in 1:size(resvec1,1)] |> combinedims |> _t
	end
	return res
end
"""
    viewstruc(args)

Create and return a Makie Figure for a PDB structure.
# Examples
```julia
using BioStructures
struc = retrievepdb("2vb1", dir = "data/") |> Observable
sv = viewstruc(struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
sv = viewstruc(struc)
```
Keyword arguments:
resolution ---- Default - (800,800)
atmcolors ----- Default - "element", define your own dict for atoms like: "N" => :blue
atmscale ------ Default - 1/3, size adjustment of atom radii
figdims ------- Default - [13,10], GridLayout dimensions for structure view: 'fig = Figure(); fig[ 1:(figdims[1]), 1:(figdims[2]) ]'
"""
function viewstruc( struc::T,
					selectors = [standardselector];
					resolution = (800,800),
					atmcolors = "element",
					atmscale = 1/3,
					figdims = [13,10]
					) where {T<:Observable}
    atms = @lift BioStructures.collectatoms($struc,selectors...)
    atmcords = @lift atomcoords($atms)
    colr = @lift atomcolors($atms; color = atmcolors)
    marksize = @lift (atmscale).*atomradii($atms)
    fig = Figure(resolution = resolution)
    ly = fig[ 1:(figdims[1]), 1:(figdims[2]) ]
    plt = meshscatter(ly, atmcords; show_axis = false, color = colr, markersize = marksize)
	resshps = @lift bondshape(SplitApplyCombine.flatten(bonds(collectresidues($struc,selectors...))))
	bbshps = @lift bondshape(SplitApplyCombine.flatten(backbonebonds.(collectchains($struc))))
	resbnds = @lift normal_mesh.($resshps)
	bckbnds = @lift normal_mesh.($bbshps)
	mesh!(ly, resbnds, color = RGBA(0.5,0.5,0.5,0.8))
	mesh!(ly, bckbnds, color = RGBA(0.5,0.5,0.5,0.8))
    fig
end
