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
						[elecolors[element(x)] for x in atoms]
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

function viewstruc(str::String; dir = "../data/PDB", showbonds = true, color = :element)
	sv = structureview(str; dir = dir)
	scene, layout = layoutscene(8, 8; resolution = (900,900))
	sc_scene = layout[2:8,1:8] = LScene(scene)
	pdbtext = layout[1,1:8] = LText(scene, text = uppercase(str); textsize = 35)
	colors = Node(color)

	meshscatter!(sc_scene, lift(atomcoords,sv.atoms);
		color = lift(X->atomcolors(X; color = colors[]),sv.atoms),
		markersize = lift(X->(1/3).*atomradii(X),sv.atoms), show_axis = false)

	if showbonds == true
		bonds1 = normal_mesh.(bondshapes(bonds(residues(sv))))
		mesh!(sc_scene, bonds1[1], color = RGBAf0(0.5,0.5,0.5,0.8))
		for i = 1:size(bonds1,1); mesh!(sc_scene, bonds1[i], color = RGBAf0(0.5,0.5,0.5,0.8)); end
	end
	display(scene)
	sc_scene.scene.center = false

	sv.scenes = [scene,sc_scene]
	sv.layout = layout
	return sv
end
