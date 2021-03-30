atomcoords(atoms) = coordarray(atoms) |> transpose |> collect
atomcolors(atoms; color = "element") =
					if color == "ele" || color == "element" || color == :ele || color == :element
						[elecolors[element(x)] for x in atoms]
					elseif color == "aqua" || color == :aqua
						[aquacolors[element(x)] for x in atoms]
					else
						try
							[color[element(x)] for x in atoms]
						catch
							try
								d = @eval $(color)*"colors"
								[d[element(x)] for x in atoms]
							catch
								println("color dict not found")
							end
						end
					end
atomradii(atoms) = [vanderwaals[element(x)] for x in atoms]
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
sv = viewstruc("2VB1")
```
"""
function viewstruc( struc::T;
					dir = "",
					show_bonds = true,
					show_id = true,
					id_size = 25,
					selectors = [standardselector],
					atmcolors = "element"
					) where {T}
    if !(T<:Node)
        if T<:String
            struc = Node(pdbS(struc))
        else
            struc = Node(struc)
        end
    end
    atms = @lift BioStructures.collectatoms($struc,selectors...)
    atmcords = @lift atomcoords($atms)
    colr = lift(X->atomcolors(X; color = atmcolors),atms)
    marksize = lift(X->(1/3).*atomradii(X),atms)
    fig = Figure(resolution = (800,800))
    ly = fig[2:10,1]
    plt = meshscatter(ly, atmcords; show_axis = false, color = colr, markersize = marksize)
    if show_bonds == true
        shps = @lift bondshapes.(bonds(collectresidues($struc,standardselector))) |> collectbondshapes
        bnds = @lift normal_mesh.($shps)
        mesh!(ly, bnds, color = RGBAf0(0.5,0.5,0.5,0.8))
    end
    if show_id == true
    	try
    		id = @lift $struc.name[1:end-4]
    		Label(fig[1,1], id, tellwidth = false, tellheight = false, textsize = id_size)
    	catch
    		try
    			id = @lift $struc.structure.name[1:end-4]
    			Label(fig[1,1], id, tellwidth = false, tellheight = false, textsize = id_size)
    		catch
    			id = @lift $struc.model.structure.name[1:end-4]
    			Label(fig[1,1], id, tellwidth = false, tellheight = false, textsize = id_size)
    		end
    	end
    end
    fig
end
