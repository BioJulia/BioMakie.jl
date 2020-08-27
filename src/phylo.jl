mutable struct PhyloView
	data
	models
	scenes
	layout
end
PhyloView(xs::AbstractArray{Node}) = PhyloView(xs..., [], [])

for f in (	:data,
			:models
			)
  @eval $(f)(yv::PhyloView) = yv.$(f)[]
end

function phyloview( name::String;
					dir = "../data/NWK",
					models = "")
	file1 = open(t -> parsenewick(t, NamedPolytomousTree), name)
    evolve(x) = Phylo.map_depthfirst((val, node) -> val, 0., x, Float64)
	models = evolve(file1)
	return PhyloView(  map( X->Node(X),
								[ file1,
								  models
								]))
end

# This was borrowed from Phylo.jl
function viewphylo(name::AbstractString)
	yv = phyloview(name)
	# exp1 = yv.models
    # scene, layout = layoutscene(resolution = (1000, 1000))
    # sc2 = layout[1:8,8:11] = LScene(scene)
    # scp = recipeplot!(
    #     sc2,
    #     exp1;
    #     treetype = :fan, #:fan :dendrogram
    #     line_z = yv.data,
    #     # linewidth = 1,
    #     # showtips = false,
    #     cgrad = :viridis,
    #     seriestype = :path,
    #     # scale_plot = true, # Makie attributes can be used here as well!
    #     show_axis = false
    # )
	#
	# display(scene)
	#
	# yv.scenes = [scene,sc2]
	# yv.layout = layout
	return yv
end

# viewphylo("C:/Users/kool7/Google Drive/BioMakie/examples/data/covidnewick.txt")
#
# using PhyloNetworks
# using PhyloPlots
