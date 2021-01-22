using GLMakie
using Pkg
Pkg.add.(["PyCall", "Conda"])
using PyCall, Conda
np = pyimport_conda("numpy", "numpy")
pyimport_conda("scipy","scipy")
spatial = pyimport_conda("scipy","spatial")
chull = pyimport_conda("scipy.spatial","ConvexHull")
skl = pyimport_conda("sklearn", "sklearn")

py"""
    from scipy.spatial import Delaunay
    import numpy as np
    from collections import defaultdict

    def alpha_shape_3D(pos, alpha):
        tetra = Delaunay(pos)
        tetrapos = np.take(pos,tetra.vertices,axis=0)
        normsq = np.sum(tetrapos**2,axis=2)[:,:,None]
        ones = np.ones((tetrapos.shape[0],tetrapos.shape[1],1))
        a = np.linalg.det(np.concatenate((tetrapos,ones),axis=2))
        Dx = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[1,2]],ones),axis=2))
        Dy = -np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,2]],ones),axis=2))
        Dz = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,1]],ones),axis=2))
        c = np.linalg.det(np.concatenate((normsq,tetrapos),axis=2))
        r = np.sqrt(Dx**2+Dy**2+Dz**2-4*a*c)/(2*np.abs(a))
        tetras = tetra.vertices[r<alpha,:]
        TriComb = np.array([(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)])
        Triangles = tetras[:,TriComb].reshape(-1,3)
        Triangles = np.sort(Triangles,axis=1)
        TrianglesDict = defaultdict(int)
        for tri in Triangles:
            TrianglesDict[tuple(tri)] += 1
        Triangles=np.array([tri for tri in TrianglesDict if TrianglesDict[tri] ==1])
        EdgeComb=np.array([(0, 1), (0, 2), (1, 2)])
        Edges=Triangles[:,EdgeComb].reshape(-1,2)
        Edges=np.sort(Edges,axis=1)
        Edges=np.unique(Edges,axis=0)
        Vertices = np.unique(Edges)
        return Vertices,Edges,Triangles
    """

function getalphashape(coords::AbstractArray, alpha::T) where {T<:Real}
    verts,edges,tris = py"alpha_shape_3D($(coords),$(alpha))"
    return [indexshift(verts),indexshift(edges),indexshift(tris)]
end
function viewalphashape(str::String)
	sv = structureview(str)
	scene1, layout = layoutscene(8, 8; resolution = (1000,1000))
	sc_scene = layout[2:8,1:6] = LScene(scene1, resolution = (1000,1000))
	alpha1 = layout[3,7:8] = LSlider(scene1, range = 1.5:0.01:9.0, startvalue = 2.5)
	alphatxt1 = Makie.lift(alpha1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
	pdbtext = layout[1,1:6] = LText(scene1, text = uppercase(str); textsize = 35)
	alphatext = layout[2,7:8] = LText(scene1, text = alphatxt1)
	atms = atomcoords(sv.atoms[])
	sliderval = alpha1.value
	protatms = sv.atoms
	proteinshape = @lift let a = $protatms; getalphashape(atomcoords(a),$sliderval); end
	alphaconnect = Makie.lift(proteinshape) do a1; tryint.(a1[3]); end
	alphaedges = @lift atomcoords(sv)[tryint.($(proteinshape)[2]),:] |> linesegs
	alphaverts = @lift atomcoords(sv)[tryint.($(proteinshape)[1]),:]
	surfarea = @lift surfacearea(atomcoords(sv), tryint.($(proteinshape)[3]))
	surfatext = layout[4,7:8] = LText(scene1, text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 15)

	scatter!(sc_scene, alphaverts, markersize = 0.5, color = :blue, show_axis = false)
	linesegments!(sc_scene, alphaedges, color = :green, show_axis = false)

	AbstractPlotting.display(scene1)
	sc_scene.scene.center = false

	sv.scenes = [scene1,sc_scene]
	sv.layout = layout
	return sv
end

asv = viewalphashape("2vb1")
