atomcoords(atoms) = coordarray(atoms) |> transpose |> collect
atomcolors(atoms; color = "element") =
					if color == "ele" || color == "element" || color == :ele || color == :element
						[elecolors[BioStructures.element(x)] for x in atoms]
					elseif color == "aqua" || color == :aqua
						[aquacolors[BioStructures.element(x)] for x in atoms]
					else
						try
							[color[BioStructures.element(x)] for x in atoms]
						catch
							try
								d = @eval $(color)*"colors"
								[d[BioStructures.element(x)] for x in atoms]
							catch
								println("color dict not found")
							end
						end
					end
atomradii(atoms) = [vanderwaals[BioStructures.element(x)] for x in atoms]
resids(residues) = resid.(residues)
function resatoms(res; typ = :OrderedDict)
	resvec1 = [k for k in res]
	if typ in (:OrderedDict, :ordereddict, :odict, OrderedDict)
		resvec2 = [(resvec1[i].name, coords(resvec1[i])) for i in 1:size(resvec1,1)]
		return OrderedDict(resvec2)
	elseif typ in (:Dict, :dict, Dict)
		resvec2 = [(resvec1[i].name, coords(resvec1[i])) for i in 1:size(resvec1,1)]
		return Dict(resvec2)
	elseif typ in (:ComponentArray, :comp, ComponentArray)
		resvec2 = [(resvec1[i].name, coords(resvec1[i])) for i in 1:size(resvec1,1)]
		resvec3 = dict2ntuple(Dict(resvec2))
		return ComponentArray(resvec3)
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
struc = retrievepdb("2vb1", dir = "data\\") |> Node
sv = viewstruc(struc)

struc = read("data\\2vb1_mutant1.pdb", BioStructures.PDB) |> Node
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
					) where {T<:Node}
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
	mesh!(ly, resbnds, color = RGBAf0(0.5,0.5,0.5,0.8))
	mesh!(ly, bckbnds, color = RGBAf0(0.5,0.5,0.5,0.8))
    fig
end
