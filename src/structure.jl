mutable struct StructureView
	protein
	models
	chains
	residues
	atoms
	scenes
	layout
end
StructureView(xs::AbstractArray{Node}) = StructureView(xs..., [], [])

for f in (	:protein,
			:models,
			:chains,
			:residues,
			:atoms
			)
  @eval $(f)(sv::StructureView) = sv.$(f)[]
end

atomcoords(atoms) = coordarray(atoms) |> transpose |> collect
atomcoords(sv::StructureView) = coordarray(sv.atoms[]) |> transpose |> collect
atomcolors(atoms; color = "element") =
					if color == "ele" || color == "element"
						[elecolors[element(x)] for x in atoms]
					elseif color == "aqua"
						[aquacolors[element(x)] for x in atoms]
					end
atomradii(atoms) = [vanderwaals[element(x)] for x in atoms]
resids(residues) = resid.(residues)
resatoms(residues) = BioStructures.atoms.(residues)
bonds(residus) = resbonds.(residus; hres = true)
bondshapes(bonds) = bondshape.([bonds[i].bonds for i = 1:size(bonds,1)]) |> collectbondshapes

"""
    structureview(str::String; kwargs...)

Return a StructureView object with PDB ID `"str"`.

### Optional Arguments:
- dir (String)         - Directory of PDB structure, default `"../data/PDB"`
- showbonds (Boolean)  - To display bonds, default `true`
- colors (String)      - Color set for atoms, default `"element"`

"""
function structureview(str::String;
						dir = "../data/PDB",
						select = :standardselector)

	id = uppercase(str)
	prot = retrievepdb(id; dir = dir)
	models1 = BioStructures.models(prot)
	chains1 = BioStructures.chains(prot)
	residues1 = BioStructures.collectresidues(prot, eval(select))
	atoms1 = BioStructures.collectatoms(prot, eval(select))
	return StructureView(  map( X->Node(X),
								[ prot,
							  	  models1,
							  	  chains1,
							  	  residues1,
							  	  atoms1
								]))
end

"""
    viewstrucs(strs::AbstractArray{String}; kwargs...)

Visualize all structures in the array `strs`.

### Optional Arguments:
- dir (String)         - Directory of PDB structure, default `"../data/PDB"`
- showbonds (Boolean)  - To display bonds, default `true`
- colors (String)      - Color set for atoms, default `"element"`

"""
function viewstrucs(strs::AbstractArray{String};
					dir = "../data/PDB",
					showbonds = true,
					colors = "element")

	len = length(strs)
	len > 0 || throw("length of input for `viewstrucs` must be > 0")
    scene, layout = layoutscene(1, 1; resolution = (1200,900))
    svs = [structureview(string(str); dir = dir) for str in strs]
    sc_scenes = [LScene(scene) for s in strs]
    pdbtexts = [LText(scene, text = uppercase(str); textsize = 35-len) for str in strs]
	colors = Node(colors)

    for i in 1:len
        sc = sc_scenes[i]
        pt = pdbtexts[i]
        layout[2:8,(end+1):(end+8)] = sc
        layout[1,(end-4):(end-3)] = pt
        meshscatter!(sc, lift(atomcoords,svs[i].atoms);
            color = lift(X->atomcolors(X; color = colors[]),svs[i].atoms),
            markersize = lift(X->(1/3).*atomradii(X),svs[i].atoms), show_axis = false)
        if showbonds == true
    		bonds1 = normal_mesh.(bondshapes(bonds(residues(svs[i]))))
    		mesh!(sc, bonds1[1], color = RGBAf0(0.5,0.5,0.5,0.8))
    		for i = 1:size(bonds1,1); mesh!(sc, bonds1[i], color = RGBAf0(0.5,0.5,0.5,0.8), backgroundcolor = RGBAf0(0.5,0.5,0.5,0.8)); end
    	end
        svs[i].scenes = [scene,sc]
        svs[i].layout = layout
    end
    AbstractPlotting.display(scene)
    deletecol!(layout, 1)
    if len == 1
        return svs[1]
    end
	return svs
end

"""
    viewstruc(str::{String}; kwargs...)

Visualize structure with PDB ID `"str"`.

### Optional Arguments:
- dir (String)         - Directory of PDB structure, default `"../data/PDB"`
- showbonds (Boolean)  - To display bonds, default `true`
- colors (String)      - Color set for atoms, default `"element"`

"""
viewstruc(str::String; kwargs...) = viewstrucs([str]; kwargs...)
viewstruc(stv::StructureView; kwargs...) = viewstrucs([stv]; kwargs...)
