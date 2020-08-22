mutable struct PhyloView
	phylodata::Node
	expansion::Node
	scenes
	layout
end
PhyloView(xs::AbstractArray{Node}) = PhyloView(xs..., [], [])

for f in (	:phylodata,
			:expansion
			)
  @eval $(f)(mv::PhyloView) = mv.$(f)[]
end

function phyloview(name::String;
					dir = "../data/NWK")
	file1 = open(t -> parsenewick(t, NamedPolytomousTree), name)
    evolve(tree) = Phylo.map_depthfirst((val, node) -> val, 0., tree, Float64)
	expansion = []
	return PhyloView(  map( X->Node(X),
								[ file1,
								  expansion
								]))
end

# This was borrowed from Phylo.jl
function viewphylo(name::AbstractString)
	yv = phyloview(name)
    scene, layout = layoutscene(resolution = (1000, 1000))
    sc2 = layout[1:8,8:11] = LScene(scene)
    scp = recipeplot!(
        sc2,
        phylodata(yv) |> evolve;
        treetype = :dendrogram, #:fan :dendrogram
        line_z = phylodata(yv) |> evolve,
        linewidth = 1,
        showtips = false,
        cgrad = :viridis,
        seriestype = :path,
        scale_plot = true, # Makie attributes can be used here as well!
        show_axis = false
    )

	display(scene)

	yv.scenes = [scene,ax1]
	yv.layout = layout
	return yv
end

# viewphylo("C:/Users/kool7/Google Drive/BioMakie/examples/data/covidnewick.txt")
