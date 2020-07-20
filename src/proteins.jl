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

function viewstruc(str::String; dir = "../data/PDB", showbonds = true)
	sv = structureview(str; dir = dir)
	scene, layout = layoutscene(16, 9; resolution = (900,900))
	sc_scene = layout[1:14,1:6] = LScene(scene)
	markersize1 = layout[4,7:9] = LSlider(scene, range = 0:0.01:3.0, startvalue = 0.5)
	markersizetext1 = layout[3,7:9] = LText(scene, lift(X->"atom size = $(string(X))", markersize1.value))
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
function collectbondshapes(arr)
	shapes = []
	for i = 1:size(arr,1)
		for j = 1:size(arr[i],1)
			push!(shapes,arr[i][j])
		end
	end
	return shapes |> Vector{GeometryBasics.Cylinder{3,Float32}}
end
# # using Pkg
# # Pkg.add.(["PyCall", "Conda"])
# using PyCall, Conda
#     np = pyimport_conda("numpy", "numpy")
#     pyimport_conda("scipy","scipy")
#     spatial = pyimport_conda("scipy","spatial")
#     chull = pyimport_conda("scipy.spatial","ConvexHull")
#     skl = pyimport_conda("sklearn", "sklearn")
#
#     py"""
#         from scipy.spatial import Delaunay
#         import numpy as np
#         from collections import defaultdict
#
#         def alpha_shape_3D(pos, alpha):
#             tetra = Delaunay(pos)
#             # Find radius of the circumsphere.
#             # By definition, radius of the sphere fitting inside the tetrahedral needs
#             # to be smaller than alpha value
#             # http:///mathworld.wolfram.com/Circumsphere.html
#             tetrapos = np.take(pos,tetra.vertices,axis=0)
#             normsq = np.sum(tetrapos**2,axis=2)[:,:,None]
#             ones = np.ones((tetrapos.shape[0],tetrapos.shape[1],1))
#             a = np.linalg.det(np.concatenate((tetrapos,ones),axis=2))
#             Dx = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[1,2]],ones),axis=2))
#             Dy = -np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,2]],ones),axis=2))
#             Dz = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,1]],ones),axis=2))
#             c = np.linalg.det(np.concatenate((normsq,tetrapos),axis=2))
#             r = np.sqrt(Dx**2+Dy**2+Dz**2-4*a*c)/(2*np.abs(a))
#
#             # Find tetrahedrals
#             tetras = tetra.vertices[r<alpha,:]
#             # triangles
#             TriComb = np.array([(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)])
#             Triangles = tetras[:,TriComb].reshape(-1,3)
#             Triangles = np.sort(Triangles,axis=1)
#             # Remove triangles that occurs twice, because they are within shapes
#             TrianglesDict = defaultdict(int)
#             for tri in Triangles:
#                 TrianglesDict[tuple(tri)] += 1
#             Triangles=np.array([tri for tri in TrianglesDict if TrianglesDict[tri] ==1])
#             EdgeComb=np.array([(0, 1), (0, 2), (1, 2)])
#             Edges=Triangles[:,EdgeComb].reshape(-1,2)
#             Edges=np.sort(Edges,axis=1)
#             Edges=np.unique(Edges,axis=0)
#             Vertices = np.unique(Edges)
#             return Vertices,Edges,Triangles
#         """
#
# function getalphashape(coords::AbstractArray, alpha::T) where {T<:Real}
#     verts,edges,tris = py"alpha_shape_3D($(coords),$(alpha))"
#     return [indexshift(verts),indexshift(edges),indexshift(tris)]
# end
# function viewalphashape(str::String; dir = "../data/PDB")
# 	sv = structureview(str; dir = dir)
# 	scene, layout = layoutscene(16, 8; resolution = (900,900))
# 	sc_scene = layout[1:14,1:6] = LScene(scene, show_axis = false)
# 	alpha1 = layout[3,7:8] = LSlider(scene, range = 0:0.01:3.0, startvalue = 0.5)
# 	txt1 = Makie.lift(alpha1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
# 	top_text = layout[2,7:8] = LText(scene, text = txt1)
# 	atms = atomcoords(sv.atoms[])
# 	sliderval = alpha1.value
# 	protatms = sv.atoms
# 	proteinshape = @lift let a = $protatms; getalphashape(atomcoords(a),$sliderval); end
# 	alphaconnect = Makie.lift(proteinshape) do a1; a1[3]; end
# 	alphaedges = @lift atomcoords(sv)[$(proteinshape)[2],:] |> linesegs
# 	alphaverts = @lift atomcoords(sv)[$(proteinshape)[1],:]
# 	surfarea = @lift surfacearea(atomcoords(sv), $(proteinshape)[3])
# 	bottom_texts = layout[8,7:8] = LText(scene, text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 15)
#
# 	# mesh!(sc_scene, alphaverts, alphaconnect)
# 	scatter!(sc_scene, alphaverts, markersize = 0.5,  color = :green, show_axis = false)
# 	linesegments!(sc_scene, alphaedges, color = :green, show_axis = false)
#
# 	display(scene)
#
# 	sv.scenes = [scene,sc_scene]
# 	sv.layout = layout
# 	return sv
# end
