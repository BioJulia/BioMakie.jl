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
            # http:///mathworld.wolfram.com/Circumsphere.html
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

function getalphashape(coords::AbstractArray{Float64,2}, alpha::T) where {T<:Real}
    verts,edges,tris = py"alpha_shape_3D($(coords),$(alpha))"
    return [indexshift(verts),indexshift(edges),indexshift(tris)]
end

dir1 = "C:/Users/kool7/Google Drive/data/Lysozyme - PF00062/2VB1modes"
# proteinview = viewstruc("1lw3")
proteinview = viewstruc("2VB1"; dir = dir1)

# loadframes("6M0J",)
# atoms(proteinview)
# coords.(atoms(proteinview)) |> combinedims
# atms = atomcoords(proteinview.atoms[])
proteinview.atoms[] .|> serial
# atomcoords(proteinview)
# scene, layout = layoutscene(resolution = (600,900))
# sc1 = layout[1,1:3] = LScene(scene, show_axis = false)
slider1 = proteinview.layout[6,7:8] = LSlider(proteinview.scenes[1], range = 1.1:0.1:10.0, startvalue = 2.0)
txt1 = Makie.lift(slider1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
top_text = proteinview.layout[5,7:8] = LText(proteinview.scenes[1], text = txt1)
# scene, layout = layoutscene()
# sc1 = layout[1,1:3] = LScene(scene, show_axis = false)
# slider1 = Node(2.0)
# txt1 = "alpha = "
# top_text = txt1
# bottom_texts = layout[4,2] = LText(scene, text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 15)

atms = atomcoords(proteinview.atoms[])
proteinshape = Makie.lift(slider1.value) do a; getalphashape(atms,a); end
alphaconnect = Makie.lift(proteinshape) do a1
                            a1[3]
                        end
alphaedges = @lift atomcoords(proteinview)[$(proteinshape)[2],:] |> linesegs
alphaverts = @lift atomcoords(proteinview)[$(proteinshape)[1],:]

surfarea = @lift surfacearea(atomcoords(proteinview), $(proteinshape)[3])
bottom_texts = proteinview.layout[8,7:8] = LText(proteinview.scenes[1], text = lift(X->string("surface area = ", round(Int64, X), "  Å"), surfarea), textsize = 20)

# sc1 = proteinview.layout[1:14,9:15] = LScene(proteinview.scenes[1], show_axis = false)
# bonds1 = normal_mesh.(bondshapes(bonds(residues(proteinview))))
# mesh!(sc1, bonds1[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.8))
# for i = 1:size(bonds1,1); mesh!(sc1, bonds1[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)); end

# mesh!(proteinview.scenes[2],alphaverts, alphaconnect)
scatter!(proteinview.scenes[2], alphaverts, markersize = 1.0,  color = :green, show_axis = false)
linesegments!(proteinview.scenes[2], alphaedges, color = :green, show_axis = false)
# scatter!(sc1, proteinview.coords, markersize = 1.0,  color = :green, show_axis = false)
# sc1.scene.center = false
sc1 = proteinview.scenes[2]
proteinview.scenes[1]
# cameracontrols!(sc1.scene).rotationspeed = 0.03
sc2, layout2 = layoutscene(resolution = (600,900))
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

sv = viewalphashape("6M0J")

sv = structureview("2VB1")
scene, layout = layoutscene(16, 8; resolution = (900,900))
sc_scene = layout[1:14,1:6] = LScene(scene, show_axis = false)
alpha1 = layout[3,7:8] = LSlider(scene, range = 0:0.01:3.0, startvalue = 0.5)
txt1 = Makie.lift(alpha1.value) do s1; string("Alpha = ", round(s1, sigdigits = 2)); end
top_text = layout[2,7:8] = LText(scene, text = txt1)
atms = atomcoords(sv.atoms[])

proteinshape = Makie.lift(alpha1.value) do a; getalphashape(@show atms,a); end
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

#
# using Flux3D
#
#
# using Flux3D, Flux, Zygote
# using Parameters: @with_kw
# using Flux: onehotbatch, onecold, onehot, crossentropy
# using Statistics: mean
# using Base.Iterators: partition
#
# using CUDAapi
# if has_cuda()
#     @info "CUDA is on"
#     import CuArrays
#     CuArrays.allowscalar(false)
# end
#
# @with_kw mutable struct Args
#     K::Int = 10 # k nearest-neighbors
#     batch_size::Int = 32
#     lr::Float64 = 3e-4
#     epochs::Int = 50
#     num_classes::Int = 10 #possible values {10,40}
#     npoints::Int = 1024
#     cuda::Bool = true
#     device = cpu
# end
#
# function get_processed_data(args)
#     # Fetching the train and validation data and getting them into proper shape
#     if args.num_classes == 10
#         dset = ModelNet10.dataset(;mode=:pointcloud, npoints=args.npoints, transform=NormalizePointCloud())
#     elseif args.num_classes == 40
#         dset = ModelNet40.dataset(;mode=:pointcloud, npoints=args.npoints, transform=NormalizePointCloud())
#     else
#         error("ModelNet dataset with $(args.num_classes) is not supported.
#                 Currently supported num_classes for ModelNet dataset is {10,40}")
#     end
#
#     data = [dset[i].data.points for i in 1:length(dset)]
#     labels = onehotbatch([dset[i].ground_truth for i in 1:length(dset)],1:args.num_classes)
#
#     #onehot encode labels of batch
#     train = [(cat(data[i]..., dims = 3), labels[:,i]) for i in partition(1:length(data), args.batch_size)] .|> args.device
#
#     if args.num_classes == 10
#         VAL = ModelNet10.dataset(;mode=:pointcloud, train=false, npoints=args.npoints, transform=NormalizePointCloud())
#     elseif args.num_classes == 40
#         VAL = ModelNet40.dataset(;mode=:pointcloud, train=false, npoints=args.npoints, transform=NormalizePointCloud())
#     else
#         error("ModelNet dataset with $(args.num_classes) is not supported.
#                 Currently supported num_classes for ModelNet dataset is {10,40}")
#     end
#
#     valX = cat([VAL[i].data.points for i in 1:length(VAL)]..., dims=3) |> args.device
#     valY = onehotbatch([VAL[i].ground_truth for i in 1:length(VAL)], 1:args.num_classes) |> args.device
#
#     val = (valX,valY)
#     return train, val
# end
#
# function train(; kwargs...)
#     # Initialize the hyperparameters
#     args = Args(; kwargs...)
#
#     # GPU config
#     if args.cuda && has_cuda()
#         args.device = gpu
#         @info("Training on GPU")
#     else
#         args.device = cpu
#         @info("Training on CPU")
#     end
#
#     @info("Loading Data...")
#     # Load the train, validation data
#     train,val = get_processed_data(args)
#
#     @info("Initializing Model...")
#     # Defining the loss and accuracy functions
#     m = DGCNN(args.num_classes, args.K, args.npoints) |> args.device
#
#     loss(x, y) = crossentropy(m(x), y)
#     accuracy(x, y) = mean(onecold(cpu(m(x)), 1:args.num_classes) .== onecold(cpu(y), 1:args.num_classes))
#
#     ## Training
#     opt = ADAM(args.lr)
#     @info("Training...")
#     # Starting to train models
#     custom_train!(loss, params(m), train, opt, args.epochs, val, accuracy)
#
#     return m
# end
#
# function custom_train!(loss, ps, data, opt, epochs, (valX, valY), accuracy)
#     ps = Zygote.Params(ps)
#     for epoch in 1:epochs
#         running_loss = 0
#         for d in data
#         gs = gradient(ps) do
#             training_loss = loss(d...)
#             running_loss += training_loss
#             return training_loss
#         end
#         Flux.update!(opt, ps, gs)
#         end
#         print("Epoch: $(epoch), epoch_loss: $(running_loss), accuracy: $(accuracy(valX, valY))\n")
#     end
# end
#
# m = train()
#
# import Makie.AbstractPlotting.meshscatter
#
# import Flux3D.visualize
#
# """
#     visualize(pcloud::PointCloud; kwargs...)
# Visualize PointCloud `pcloud`.
# Dimension of points in PointCloud `pcloud` must be 3.
# ### Optional Arguments:
# - color (Symbol)        - Color of the marker, default `:blue`
# - markersize (Number)   - Size of the marker, default `0.02*npoints(pcloud)/1024`
# """
# function visualize(v::PointCloud; kwargs...)
#     size(v.points,2)==3 || error("dimension of points in PointCloud must be 3.")
#
#     kwargs = convert(Dict{Symbol, Any}, kwargs)
#     get!(kwargs, :color, :blue)
#     get!(kwargs, :markersize, 0.02*npoints(v)/1024)
#
#     meshscatter(v.points[:,1],v.points[:,2],v.points[:,3]; kwargs...)
# end
#
# visualize(v::Dataset.AbstractDataPoint; kwargs...) = visualize(v.data; kwargs...)
#
# visualize(v::AbstractCustomObject; kwargs...) = error("Define visualize function for custom type: $(typeof(v)).
#                                                         Use `import Flux3D.visualize` and define function
#                                                         `visualize(v::$(typeof(v)); kwargs...)`")
#
