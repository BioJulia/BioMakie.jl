structureviewimport BioStructures: retrievepdb, chains, coords, resids, Chain, AbstractAtom
import Makie: plot, plot!, Node, lift
import MIToS: PDB.getpdbdescription
mutable struct StructureView
	pdbid::Node{String}
	protein::Node{ProteinStructure}
	chains::Node{Dict{String,Chain}}
	atoms::Node{Array{AbstractAtom,1}}
	coords::Node{Array{Float64,2}}
	internaldistances::Node{Array{Float64,2}}
	atomcolors::Node{Array}
	atomradii::Node{Array{Float64,1}}
	residues::Node{Array{AbstractResidue,1}}
	resids::Node{Array{String,1}}
	resatoms::Node{Array{Dict{String,AbstractAtom},1}}
	descript::Node{Array{AbstractString,2}}
	bonds::Node{Array}
	bondshapes::Node{Array{GeometryPrimitive,1}}
end
for f in (	:pdbid,
			:protein,
			:chains,
			:atoms,
			:coords,
			:internaldistances,
			:atomcolors,
			:atomradii,
			:residues,
			:resids,
			:resatoms,
			:descript,
			:bonds,
			:bondshapes )
  @eval $(f)(pv::StructureView) = pv.$(f)[]
end
function structureview(str::String; color = :element)
	pdbid = uppercase(str)
	protein = retrievepdb(pdbid;)
	chainss = chains(protein)
	atoms = collectatoms(protein[collect(keys(chainss(1)))[1]])
	coords = coordarray(atoms) |> transpose |> collect
	internaldists = internaldistances(atoms)
	atomcolors = if color == :ele || color == :element
		[elecolors[element(x)] for x in atoms]
	else
		[aquacolors[element(x)] for x in atoms]
	end
	atomradii = [vanderwaals[element(x)] for x in atoms]
	residues = collectresidues(atoms)
	resids = resid.(residues)
	resatoms = BioStructures.atoms.(residues)
	descript = [getpdbdescription(pdbid) |> keys |> collect, getpdbdescription(pdbid) |> values |> collect] |> combinedims
	bonds = resbonds.(residues; hres = true)
	bondshapes = bondshape.([bonds[i].bonds for i = 1:size(bonds,1)]) |> collectbondshapes
	return StructureView( map(X->Node(X), [ pdbid,
										  protein,
										  chainss,
										  atoms,
										  coords,
										  internaldists,
										  atomcolors,
										  atomradii,
										  residues,
										  resids,
										  resatoms,
										  descript,
										  bonds,
										  bondshapes
										  ]
							 )
						)
end
StructureView(arr::Array{Node,1}) = StructureView(arr...)
structureview(x) = StructureView(x)
structureview(xs...) = StructureView(xs...)
structureview(x; kwargs...) = StructureView(x; kwargs...)
function plot(pv::StructureView; resolution = (900,700))
	scene, layout = layoutscene(resolution = resolution)
	sc_scene = layout[1:16,1:8] = LScene(scene)
	meshes = normal_mesh.(bondshapes(pv))
	meshscatter!(sc_scene, pv.coords, markersize = 0.5, color = pv.atomcolors, show_axis = false) # pv.atomradii
	mesh!(sc_scene, meshes[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
	for i = 1:size(meshes,1); mesh!(sc_scene, meshes[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end
	scene
end
function plot!(sc_scene, pv::StructureView)
	meshes = normal_mesh.(bondshapes(pv))
	meshscatter!(sc_scene, pv.coords, markersize = 0.5, color = pv.atomcolors, show_axis = false) # pv.atomradii
	mesh!(sc_scene, meshes[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
	for i = 1:size(meshes,1); mesh!(sc_scene, meshes[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end
end
function plot(pid::String; resolution = (900,700))
	pv = StructureView(pid)
	scene, layout = layoutscene(resolution = resolution)
	sc_scene = layout[1:16,1:8] = LScene(scene)
	meshes = normal_mesh.(bondshapes(pv))
	meshscatter!(sc_scene, pv.coords, markersize = 0.5, color = pv.atomcolors, show_axis = false) # pv.atomradii
	mesh!(sc_scene, meshes[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
	for i = 1:size(meshes,1); mesh!(sc_scene, meshes[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end
	scene
end
