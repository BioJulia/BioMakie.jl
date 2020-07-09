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
			:atoms,
			:scenes,
			:layout
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

function structureview(str::String; select = :standardselector, color = :element)
	id = uppercase(str)
	prot = retrievepdb(id; dir = "../data/PDB")
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

function viewstruc(str::String; kwargs...)
	sv = structureview(str)
	scene, layout = layoutscene(16, 8; resolution = (900,900))
	sc_scene = layout[1:14,1:6] = LScene(scene)
	markersize1 = layout[3,7:8] = LSlider(scene, range = 0:0.01:3.0, startvalue = 0.5)
	markersizetext1 = layout[2,7:8] = LText(scene, lift(X->"Atom size = $(string(X))", markersize1.value))
	meshscatter!(sc_scene, lift(atomcoords,sv.atoms); markersize = markersize1.value, color = lift(atomcolors,sv.atoms), show_axis = false, kwargs...) # sv.atomradii

	bonds1 = normal_mesh.(bondshapes(bonds(residues(sv))))
	mesh!(sc_scene, bonds1[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
	for i = 1:size(bonds1,1); mesh!(sc_scene, bonds1[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end

	display(scene)

	sv.scenes = [scene,sc_scene]
	sv.layout = layout
	return sv
end

function viewalphashape(str::String; kwargs...)
	sv = structureview(str)
	scene, layout = layoutscene(16, 8; resolution = (900,900))
	sc_scene = layout[1:14,1:6] = LScene(scene, show_axis = false)
	alpha1 = layout[3,7:8] = LSlider(scene, range = 0:0.01:3.0, startvalue = 0.5)
	txt1 = Makie.lift(alpha1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
	top_text = layout[2,7:8] = LText(scene, text = txt1)
	atms = atomcoords(sv.atoms[])

	proteinshape = Makie.lift(alpha1.value) do a; getalphashape(atms,a); end
	alphaconnect = Makie.lift(proteinshape) do a1; a1[3]; end
	alphaedges = @lift atomcoords(sv)[$(proteinshape)[2],:] |> linesegs
	alphaverts = @lift atomcoords(sv)[$(proteinshape)[1],:]
	surfarea = @lift surfacearea(atomcoords(sv), $(proteinshape)[3])
	bottom_texts = layout[8,7:8] = LText(scene, text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 15)

	mesh!(sc_scene, alphaverts, alphaconnect)
	scatter!(sc_scene, alphaverts, markersize = 0.5,  color = :green)
	linesegments!(sc_scene, alphaedges, color = :green)

	display(scene)

	sv.scenes = [scene,sc_scene]
	sv.layout = layout
	return sv
end

# pkg"up"
# pkg"add https://github.com/nirmal-suthar/Flux3D.jl#ns/mesh"
# pkg"add Flux Zygote AbstractPlotting GLMakie GeometryBasics"
# pkg"precompile"
# using Flux3D, Zygote, Flux, FileIO, Statistics, GLMakie, AbstractPlotting
# import GeometryBasics
