mutable struct StructureView
	protein::Node{ProteinStructure}
	models::Node{Dict{Int,Model}}
	chains::Node{Dict{String,Chain}}
	residues::Node{Vector{AbstractResidue}}
	atoms::Node{Vector{AbstractAtom}}
end
StructureView(xs::AbstractArray{Node}) = StructureView(xs...)

for f in (	:protein,
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
bonds(residus) = resbonds.(residus; hres = true)
bondshapes(bonds) = bondshape.([bonds[i].bonds for i = 1:size(bonds,1)]) |> collectbondshapes

function structureview(str::String; select = :standardselector, color = :element)
	id = uppercase(str)
	prot = retrievepdb(id; dir = "../data/PDB")
	models1 = BioStructures.models(prot)
	chains1 = BioStructures.chains(prot)
	residues1 = BioStructures.collectresidues(prot, eval(select))
	atoms1 = BioStructures.collectatoms(prot, eval(select))
	return StructureView(	map( X->Node(X),
								[prot,
							  	models1,
							  	chains1,
							  	residues1,
							  	atoms1] )
						)
end

function viewstruc(str::String; kwargs...)
	sv = structureview(str)
	scene, layout = layoutscene(16, 8; resolution = (900,700))
	sc_scene = layout[1:14,1:6] = LScene(scene)
	markersize1 = layout[3:4,7:8] = LSlider(scene, range = 0:0.01:3.0, startvalue = 0.5)

	meshes = normal_mesh.(bondshapes(bonds(residues(sv))))
	meshscatter!(sc_scene, lift(atomcoords,sv.atoms); markersize = markersize1.value, color = lift(atomcolors,sv.atoms), show_axis = false, kwargs...) # sv.atomradii
	mesh!(sc_scene, meshes[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
	for i = 1:size(meshes,1); mesh!(sc_scene, meshes[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end

	display(scene)
	return sv, scene, layout
end
