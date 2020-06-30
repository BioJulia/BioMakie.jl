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
            # Find radius of the circumsphere.
            # By definition, radius of the sphere fitting inside the tetrahedral needs
            # to be smaller than alpha value
            # http://mathworld.wolfram.com/Circumsphere.html
            tetrapos = np.take(pos,tetra.vertices,axis=0)
            normsq = np.sum(tetrapos**2,axis=2)[:,:,None]
            ones = np.ones((tetrapos.shape[0],tetrapos.shape[1],1))
            a = np.linalg.det(np.concatenate((tetrapos,ones),axis=2))
            Dx = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[1,2]],ones),axis=2))
            Dy = -np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,2]],ones),axis=2))
            Dz = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,1]],ones),axis=2))
            c = np.linalg.det(np.concatenate((normsq,tetrapos),axis=2))
            r = np.sqrt(Dx**2+Dy**2+Dz**2-4*a*c)/(2*np.abs(a))

            # Find tetrahedrals
            tetras = tetra.vertices[r<alpha,:]
            # triangles
            TriComb = np.array([(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)])
            Triangles = tetras[:,TriComb].reshape(-1,3)
            Triangles = np.sort(Triangles,axis=1)
            # Remove triangles that occurs twice, because they are within shapes
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

indexshift(args) = args.+=1
function getalphashape(coords::AbstractArray{Float64,2}, alpha::T) where {T<:Real}
    verts,edges,tris = py"alpha_shape_3D($(coords),$(alpha))"
    return indexshift.(verts,edges,tris)
end
function surfacearea(coordinates, connectivity)
    totalarea = 0.0
    for i = 1:size(connectivity,1)
        totalarea += area(GeometryBasics.Point3f0.(coordinates[connectivity[i,1],:], coordinates[connectivity[i,2],:], coordinates[connectivity[i,3],:]))
    end
    return totalarea
end
function linesegs(arrN23::AbstractArray{Float64,3})
    new_arr::AbstractArray{Point3f0} = []
    for N in 1:size(arrN23,1)
        push!(new_arr, Makie.Point3f0(arrN23[N,1,:]))
        push!(new_arr, Makie.Point3f0(arrN23[N,2,:]))
    end
    return new_arr |> combinedims |> transpose |> collect
end

proteinview = ProteinView("6LZG")

scene, layout = layoutscene(resolution = (600,900))
sc1 = layout[1,1:3] = LScene(scene, show_axis = false)
slider1 = layout[3,2] = LSlider(scene, range = 1.1:0.1:10.0, startvalue = 2.0)
txt1 = Makie.lift(slider1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
top_text = layout[2,2] = LText(scene, text = txt1)
# scene, layout = layoutscene()
# sc1 = layout[1,1:3] = LScene(scene, show_axis = false)
# slider1 = Node(2.0)
# txt1 = "alpha = "
# top_text = txt1
# bottom_texts = layout[4,2] = LText(scene, text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 15)
proteinshape = Makie.lift(slider1.value) do a; getalphashape(coords(proteinview),a); end
alphaconnect = Makie.lift(proteinshape) do a1; a1[3]; end
alphaedges = @lift coords(proteinview)[$(proteinshape)[2],:] |> linesegs
alphaverts = @lift coords(proteinview)[$(proteinshape)[1],:]
surfarea = @lift surfacearea(coords(proteinview), $(proteinshape)[3])
bottom_texts = layout[4,2] = LText(scene, text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 15)
mesh!(sc1, proteinview.coords, alphaconnect, color = Makie.RGBAf0(0.6,0.3,0.6,1.0), show_axis = false)
scatter!(sc1, alphaverts, markersize = 1.0,  color = :green, show_axis = false)
linesegments!(sc1, alphaedges, color = :green, show_axis = false)
# scatter!(sc1, proteinview.coords, markersize = 1.0,  color = :green, show_axis = false)
# sc1.scene.center = false
scene
# cameracontrols!(sc1.scene).rotationspeed = 0.03

# slider2 = layout[3,5] = LSlider(scene, range = 1.1:0.1:10.0, startvalue = 2.0)
# txt2 = Makie.lift(slider2.value) do s2; string("alpha = ", round(s2, sigdigits = 2)); end
# top_text2 = layout[2,5] = LText(scene, text = txt2)
# bottom_texts2 = layout[4,5] = LText(scene, text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 15)
scene, layout = layoutscene(resolution = (600,900))
sc3 = layout[1,1] = LScene(scene, show_axis = false)
meshes1 = normal_mesh.(bondshapes(proteinview))
meshscatter!(sc3, proteinview.coords, markersize = 0.5, color = proteinview.atomcolors, show_axis = false) # pv.atomradii
mesh!(sc3, meshes1[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8), show_axis = false)
for i = 1:size(meshes1,1); mesh!(sc3, meshes1[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8), show_axis = false); end
scene
# sc1.scene.center = false
# sc3.scene.center = false
cameracontrols(sc3.scene).lookat
sc3.layoutobservables.protrusions
nothing # NOTHINGGGGGGG!!!!!

Makie.record(scene, "alphamov.mp4") do io
    for i = 1:40
        slider1.value[] = 2.0 + i*0.2
        recordframe!(io)
    end
    for j = 40:-1:1
        slider1.value[] = 2.0 + j*0.2
        recordframe!(io)
    end
end


Makie.save("molexample.png",sc1)
