mutable struct ProteinView
	pdbid::Node
	protein::Node
	chains::Node
	atoms::Node
	coords::Node
	internaldistances::Node
	atomcolors::Node
	atomradii::Node
	residues::Node
	resids::Node
	resatoms::Node
	description::Node
	bonds::Node
	bondshapes::Node
end
import BioStructures: chains, coords, resids
import LLVM.description
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
			:description,
			:bonds,
			:bondshapes )
  @eval $(f)(pv::ProteinView) = pv.$(f)[]
end
function loadpdb(str::String)
	pdbid = uppercase(str)
	protein = begin BioStructures.downloadpdb(pdbid; pdb_dir = "$(pdbdir())"); BioStructures.readpdb(pdbid; pdb_dir = "$(pdbdir())") end
	chainss = BioStructures.chains(protein)
	atoms = collectatoms(protein[collect(keys(chainss(1)))[1]])
	coords = coordarray(atoms) |> _t
	internaldists = internaldistances(atoms)
	atomcolors = [elecolors[element(x)] for x in atoms]
	atomradii = [vanderwaals[element(x)] for x in atoms]
	_residues = collectresidues(atoms)
	resids = resid.(_residues)
	resatoms = BioStructures.atoms.(_residues)
	description = [getpdbdescription(pdbid) |> keys |> collect, getpdbdescription(pdbid) |> values |> collect] |> combinedims
	bonds = resbonds.(_residues; hres = true)
	bondshapes = bondshape.([bonds[i].bonds for i = 1:size(bonds,1)]) |> collectbondshapes
	return ProteinView( map(X->Node(X), [ pdbid,
										  protein,
										  chainss,
										  atoms,
										  coords,
										  internaldistances,
										  atomcolors,
										  atomradii,
										  _residues,
										  resids,
										  resatoms,
										  description,
										  bonds,
										  bondshapes
										  ]
							 )
						)
end
ProteinView(arr::Array{Node,1}) = ProteinView(arr...)
import AbstractPlotting: plot, plot!
function plot(pv::ProteinView; res = (900,700))
	scene, layout = layoutscene(resolution = res)
	sc_scene = layout[1:16,1:8] = LScene(scene)
	meshes = normal_mesh.(bondshapes(pv))
	meshscatter!(sc_scene, pv.coords, markersize = pv.atomradii, color = pv.atomcolors, show_axis = false)
	mesh!(sc_scene, meshes[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
	for i = 1:size(meshes,1); mesh!(sc_scene, meshes[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end
	scene
end
