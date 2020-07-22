mutable struct StructureView
	protein::Node{ProteinStructure}
	models::Node{Dict{Int,Model}}
	chains::Node{Dict{String,Chain}}
	residues::Node{Vector{AbstractResidue}}
	atoms::Node{Vector{AbstractAtom}}
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
atomcolors(atoms; color = :element) =
					if color == :ele || color == :element
						[aquacolors[element(x)] for x in atoms]
					else
						[aquacolors[element(x)] for x in atoms]
					end
atomradii(atoms) = [vanderwaals[element(x)] for x in atoms]
resids(residues) = resid.(residues)
resatoms(residues) = BioStructures.atoms.(residues)
bonds(residus) = resbonds.(residus; hres = true)
bondshapes(bonds) = bondshape.([bonds[i].bonds for i = 1:size(bonds,1)]) |> collectbondshapes

function structureview(str::String; dir = "../data/PDB", select = :standardselector, color = :element)
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
								]
							  )
						)
end

function viewstruc(str::String; dir = "../data/PDB", showbonds = true)
	sv = structureview(str; dir = dir)
	scene, layout = layoutscene(16, 9; resolution = (1000,900))
	sc_scene = layout[1:14,1:7] = LScene(scene)
	markersize1 = layout[4,8:9] = LSlider(scene, range = 0:0.01:3.0, startvalue = 0.5)
	markersizetext1 = layout[3,8:9] = LText(scene, lift(X->"atom size = $(string(X)) Å", markersize1.value))
	menu1 = layout[7,8:9] = LMenu(scene, options = ["element", "aqua"])
	menutext1 = layout[6,8:9] = LText(scene, "colors:")
	title1 = layout[0,1:7] = LText(scene, str; textsize = 35)
	meshscatter!(sc_scene, lift(atomcoords,sv.atoms); markersize = markersize1.value, color = lift(atomcolors,sv.atoms), show_axis = false) # sv.atomradii
	if showbonds == true
		bonds1 = normal_mesh.(bondshapes(bonds(residues(sv))))
		mesh!(sc_scene, bonds1[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
		for i = 1:size(bonds1,1); mesh!(sc_scene, bonds1[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end
	end
	display(scene)
	sc_scene.scene.center = false

	sv.scenes = [scene,sc_scene]
	sv.layout = layout
	return sv
end
