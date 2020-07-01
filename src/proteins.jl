mutable struct StructureView
	id::Node{String}
	protein::Node{ProteinStructure}
	models::Node{Dict{Int,Model}}
	chains::Node{Dict{String,Chain}}
	residues::Node{Array{AbstractResidue,1}}
	atoms::Node{Array{AbstractAtom,1}}
end

for f in (	:id,
			:protein,
			:models,
			:chains,
			:residues,
			:atoms
			)
  @eval $(f)(sv::StructureView) = sv.$(f)[]
end

atomcoords(atoms) = coordarray(atoms) |> transpose |> collect
atomcolors(atoms; color = :element) = if color == :ele || color == :element
						[elecolors[element(x)] for x in atoms]
					else
						[aquacolors[element(x)] for x in atoms]
					end
atomradii(atoms) = [vanderwaals[element(x)] for x in atoms]
resids(residues) = resid.(residues)
resatoms(residues) = BioStructures.atoms.(residues)
bonds(residues) = resbonds.(residues; hres = true)
bondshapes(bonds) = bondshape.([bonds[i].bonds for i = 1:size(bonds,1)]) |> collectbondshapes

function structureview(str::String; color = :element)
	id = uppercase(str)
	prot = retrievepdb(id)
	modelss = BioStructures.models(prot)
	chainss = BioStructures.chains(prot)
	residuess = BioStructures.collectresidues(prot)
	atomss = BioStructures.collectatoms(prot[collect(keys(chainss(1)))[1]])
	return StructureView( map( X->Makie.Node(X),
										  [ id,
										  	prot,
										  	modelss,
										  	chainss,
										  	residuess,
										  	atomss
										  ]
							 )
						)
end
StructureView(nodes::Array{Makie.Node,1}) = StructureView(nodes...)

sv = structureview("6LZG")
scene, layout = layoutscene(resolution = (900,700))
sc_scene = layout[1:16,1:8] = LScene(scene)

meshes = @lift normal_mesh.(bondshapes(bonds(residues(sv.))))

meshscatter!(sc_scene, lift(atomcoords,sv.atoms), markersize = 0.5, color = :gray, show_axis = false) # sv.atomradii
mesh!(sc_scene, meshes[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
for i = 1:size(meshes,1); mesh!(sc_scene, meshes[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end

scene
sv.atoms[] = sv.chains[]["A"] |> collectatoms
