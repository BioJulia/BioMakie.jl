```@meta
EditURL = "https://github.com/BioJulia/BioMakie.jl/blob/dev/docs/src/alphashape.md"
```

# Alpha shape of a protein

## Copy-pastable code (if you have PyCall + NumPy + SciPy set up)

````julia
using BioMakie
using GLMakie
using GLMakie: Slider
using SplitApplyCombine
using GeometryBasics
using Meshes
using BioStructures
using PyCall
using Conda
scipy = pyimport_conda("scipy", "scipy")
np = pyimport_conda("numpy", "numpy")
collections = pyimport_conda("collections", "collections")
py"""
    from scipy.spatial import Delaunay
    import numpy as np
    from collections import defaultdict
    def alpha_shape_3D(pos, alpha):
        tetra = Delaunay(pos)
        tetrapos = np.take(pos,tetra.simplices,axis=0)
        normsq = np.sum(tetrapos**2,axis=2)[:,:,None]
        ones = np.ones((tetrapos.shape[0],tetrapos.shape[1],1))
        a = np.linalg.det(np.concatenate((tetrapos,ones),axis=2))
        Dx = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[1,2]],ones),axis=2))
        Dy = -np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,2]],ones),axis=2))
        Dz = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,1]],ones),axis=2))
        c = np.linalg.det(np.concatenate((normsq,tetrapos),axis=2))
        r = np.sqrt(Dx**2+Dy**2+Dz**2-4*a*c)/(2*np.abs(a))
        tetras = tetra.simplices[r<alpha,:]
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
indexshift(idxs) = (idxs).+=1
function getalphashape(coords::Matrix, alpha::T) where {T<:Real}
    verts,edges,tris = py"alpha_shape_3D($(coords),$(alpha))"
    return [indexshift(verts),indexshift(edges),indexshift(tris)]
end
function getspherepoints(cords::Matrix, radius::Real)
	pnts = [GeometryBasics.Point{3,Float64}(cords[i,:]) for i in 1:size(cords,1)] |> Observable
	spheres = GeometryBasics.Point{3,Float64}[]
	lift(pnts) do p
		for i in 1:size(p,1)
			sp = GeometryBasics.decompose(GeometryBasics.Point{3,Float64},GeometryBasics.Sphere(p[i],radius),4) |> unique
			for ii in 1:size(sp,1)
				push!(spheres,sp[ii])
			end
		end
	end
	return [[spheres[i].data...] for i in 1:size(spheres,1)] |> combinedims |> transpose |> collect
end
function linesegs(arr::AbstractArray{T,3}) where T<:AbstractFloat
    new_arr::AbstractArray{Point3f0} = []
    for i in 1:size(arr,1)
        push!(new_arr, Makie.Point3f0(arr[i,1,:]))
        push!(new_arr, Makie.Point3f0(arr[i,2,:]))
    end
    return new_arr |> combinedims |> transpose |> collect
end
struc = retrievepdb("2vb1")
chn = struc[1]["A"] |> Observable
atms = collectatoms(struc, standardselector) |> Observable
cords = @lift coordarray($atms)' |> collect
fig = Figure(resolution = (800,600))
layout = fig[1,1] = GridLayout(10, 9)
strucname = struc.name[1:4]
sc_scene = layout[1:10,1:6] = LScene(fig; show_axis = false)
structxt = layout[1,7:8] = Label(fig, text = "Structure ID:  $(strucname)", fontsize = 35)
alpha1 = layout[5,7:9] = Slider(fig, range = 1.5:0.5:9.0, startvalue = 2.5)
alphatxt1 = lift(alpha1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
alphatext = layout[4,7:9] = Label(fig, text = alphatxt1, fontsize = 22)
alphaval = alpha1.value
radii1 = layout[7,7:9] = Slider(fig, range = 1.5:0.5:9.0, startvalue = 2.5)
radiixt1 = lift(radii1.value) do s1; string("atom radius = ", round(s1, sigdigits = 2)); end
radiitext = layout[6,7:9] = Label(fig, text = radiixt1, fontsize = 22)
radiival = radii1.value;
spnts = @lift getspherepoints($cords,$radiival)
proteinshape = @lift let pnts = $spnts; getalphashape(pnts,$alphaval); end
alphaverts = @lift $spnts[$(proteinshape)[1],:]
alphaedges = @lift $spnts[$(proteinshape)[2],:] |> linesegs
function surfacearea(coordinates, connectivity)
    totalarea = 0.0
    for i = 1:size(connectivity,1)
        totalarea += measure(Ngon(Meshes.Point{3,Int64}.(coordinates[connectivity[i,1],:],
                        coordinates[connectivity[i,2],:], coordinates[connectivity[i,3],:])...))
    end
    return totalarea
end
surfarea = @lift surfacearea($spnts, $(proteinshape)[3])
surfatext = layout[2,7:9] = Label(fig, text = lift(X->string("surface area = ", round(Int64, X), "  Å²"), surfarea), fontsize = 22)
linesegments!(sc_scene, alphaedges, color = :gray, transparency = true)
meshscatter!(sc_scene, cords, markersize = 0.3, color = :blue)
meshscatter!(sc_scene, alphaverts, markersize = 0.3, color = :green)
````

![alphashape](./assets/fullalphamesh.gif)

## Alpha shape walkthrough
First are the regular imports.

````julia
using BioMakie
using GLMakie
using GLMakie: Slider
using SplitApplyCombine
using GeometryBasics
using BioStructures
````

## Special imports (Python)
SciPy and NumPy are required for this alpha shape algorithm. They need to be installed in your Conda/Python environment.

````julia
using PyCall
using Conda
scipy = pyimport("scipy")
np = pyimport("numpy")
collections = pyimport("collections")
````

## Define the alpha shape algorithm.

````julia
py"""
    from scipy.spatial import Delaunay
    import numpy as np
    from collections import defaultdict

    def alpha_shape_3D(pos, alpha):
        tetra = Delaunay(pos)
        tetrapos = np.take(pos,tetra.simplices,axis=0)
        normsq = np.sum(tetrapos**2,axis=2)[:,:,None]
        ones = np.ones((tetrapos.shape[0],tetrapos.shape[1],1))
        a = np.linalg.det(np.concatenate((tetrapos,ones),axis=2))
        Dx = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[1,2]],ones),axis=2))
        Dy = -np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,2]],ones),axis=2))
        Dz = np.linalg.det(np.concatenate((normsq,tetrapos[:,:,[0,1]],ones),axis=2))
        c = np.linalg.det(np.concatenate((normsq,tetrapos),axis=2))
        r = np.sqrt(Dx**2+Dy**2+Dz**2-4*a*c)/(2*np.abs(a))
        tetras = tetra.simplices[r<alpha,:]
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
````

## Define julia alpha shape function
Python is base 0 and Julia is base 1 so we first have to define a function to shift the indices.

````julia
indexshift(idxs) = (idxs).+=1
function getalphashape(coords::Matrix, alpha::T) where {T<:Real}
    verts,edges,tris = py"alpha_shape_3D($(coords),$(alpha))"
    return [indexshift(verts),indexshift(edges),indexshift(tris)]
end
````

## Points from atomic radii spheres
Define a function to get points from spheres at a given radius around coordinates
and a function to get line segments from a set of coordinates.

````julia
function getspherepoints(cords::Matrix, radius::Real)
	pnts = [GeometryBasics.Point{3,Float64}(cords[i,:]) for i in 1:size(cords,1)] |> Observable
	spheres = GeometryBasics.Point{3,Float64}[]

	lift(pnts) do p
		for i in 1:size(p,1)
			sp = GeometryBasics.decompose(GeometryBasics.Point{3,Float64},GeometryBasics.Sphere(p[i],radius),4) |> unique
			for ii in 1:size(sp,1)
				push!(spheres,sp[ii])
			end
		end
	end

	return [[spheres[i].data...] for i in 1:size(spheres,1)] |> combinedims |> transpose |> collect
end
function linesegs(arr::AbstractArray{T,3}) where T<:AbstractFloat
    new_arr::AbstractArray{Point3f0} = []
    for i in 1:size(arr,1)
        push!(new_arr, Makie.Point3f0(arr[i,1,:]))
        push!(new_arr, Makie.Point3f0(arr[i,2,:]))
    end
    return new_arr |> combinedims |> transpose |> collect
end
````

## Load a structure and set up the figure
Load the structure with BioStructures.jl and get a coordinates Observable.
Then set up the Figure and Layout.

````julia
struc = retrievepdb("2vb1")
chn = struc[1]["A"] |> Observable
atms = collectatoms(struc, standardselector) |> Observable
cords = @lift coordarray($atms)' |> collect
fig = Figure(resolution = (800,600))
layout = fig[1,1] = GridLayout(10, 9)
````

## Add text and interactive elements
It can be helpful to run this line by line to see what is happening.

````julia
strucname = struc.name[1:4]
sc_scene = layout[1:10,1:6] = LScene(fig; show_axis = false)
structxt = layout[1,7:8] = Label(fig, text = "Structure ID:  $(strucname)", fontsize = 35)
alpha1 = layout[5,7:9] = Slider(fig, range = 1.5:0.5:9.0, startvalue = 2.5)
alphatxt1 = lift(alpha1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
alphatext = layout[4,7:9] = Label(fig, text = alphatxt1, fontsize = 22)
alphaval = alpha1.value
radii1 = layout[7,7:9] = Slider(fig, range = 1.5:0.5:9.0, startvalue = 2.5)
radiixt1 = lift(radii1.value) do s1; string("atom radius = ", round(s1, sigdigits = 2)); end
radiitext = layout[6,7:9] = Label(fig, text = radiixt1, fontsize = 22)
radiival = radii1.value;
nothing #hide
````

## Alpha shape
Lift the sphere points Observable to get the alpha shape vertices and edges.
Our `getalphashape` function returns us both at once

````julia
spnts = @lift getspherepoints($cords,$radiival)
proteinshape = @lift let pnts = $spnts; getalphashape(pnts,$alphaval); end
alphaverts = @lift $spnts[$(proteinshape)[1],:]
alphaedges = @lift $spnts[$(proteinshape)[2],:] |> linesegs
````

## Surface area
Define a function to get the surface area of a set of coordinates and connectivity.
The surface area changes when the alpha value or atom radius is changed.

````julia
using Meshes
function surfacearea(coordinates, connectivity)
    totalarea = 0.0
    for i = 1:size(connectivity,1)
        totalarea += measure(Ngon(Meshes.Point3.(coordinates[connectivity[i,1],:],
                        coordinates[connectivity[i,2],:], coordinates[connectivity[i,3],:])...))
    end
    return totalarea
end
surfarea = @lift surfacearea($spnts, $(proteinshape)[3])
surfatext = layout[2,7:9] = Label(fig, text = lift(X->string("surface area = ", round(Int64, X), "  Å²"), surfarea), fontsize = 22)
````

## Plot the shape
Finally, plot the mesh shape. Moving the sliders will update the plot. It is laggy, but it works
to construct surfaces in real time. You may want to click on the slider rather than dragging
it. Speed may be improved in the future.

````julia
linesegments!(sc_scene, alphaedges, color = :gray, transparency = true)
````

To show where the atoms are run the following line.

````julia
meshscatter!(sc_scene, cords, markersize = 0.3, color = :blue)
````

To show the alpha shape vertices run the following line.

````julia
meshscatter!(sc_scene, alphaverts, markersize = 0.3, color = :green)
````

Save the figure as a png file.

````julia
save("alphashape.png", fig)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

