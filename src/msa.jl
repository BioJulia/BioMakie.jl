# """
#     viewmsa(args)
#
# Create and return a Makie Figure for a Pfam MSA.
# # Examples
# ```julia
# vm = viewmsa("PF00062")
# ```
# """
# function viewmsa(   msa::MSA.AbstractMultipleSequenceAlignment;
# 					sheetsize = [40,20],
# 					resolution = (1500, 600),
#                     colorscheme = :viridis,
#                     colorval = 2
# 				)
#
# 	width1 = sheetsize[1]
# 	height1 = sheetsize[2]
#
# 	fig = Figure(resolution = resolution)
# 	ax1 = Axis(fig[1:7,3:9])
# 	tightlimits!(ax1)
# 	labels = msa.matrix.dicts[1] |> keys |> collect |> Node
# 	nums = msa.matrix.dicts[2] |> keys |> collect |> Node
# 	labelssize = @lift size($labels,1) - (height1-1)
# 	labelsrange = @lift $labelssize:-1:1
# 	numssize = @lift size($nums,1) - (width1-1)
# 	numsrange = @lift 1:1:$numssize
#
#     sl1 = Slider(fig[end+1,3:9], range = numsrange, startvalue = 1)
# 	sl1.value = 1
# 	sl2 = Slider(fig[1:7,10], range = labelsrange, startvalue = 1, horizontal = false,
# 		tellwidth = true, height = nothing)
# 	sl2.value = labelssize[]
#
#     colorval = Node(colorval)
# 	strmsa = Matrix(msa) .|> string
# 	strmsavals = [ kdict(i) for i in strmsa ]
# 	strmsavals2 = strmsavals |> combinedims
# 	labelshow = lift(X->labels[][(X+(height1-1):-1:X)],sl2.value)
# 	numsshow = lift(X->nums[][(X:1:X+(width1-1))],sl1.value)
# 	labelshow2 = lift(X->(X+(height1-1):-1:X),sl2.value)
# 	numsshow2 = lift(X->(X:1:X+(width1-1)),sl1.value)
# 	fixtmsa = lift(X->replace(strmsavals2[X,:,:], nothing => 0.0),colorval)
# 	msashow = @lift $fixtmsa[$labelshow2,$numsshow2] |> _t
# 	charmsa = [x[1] for x in strmsa]
# 	charshow = @lift charmsa[$labelshow2,$numsshow2]
# 	widthrange = indexshift([1:width1...],-0.5)
# 	heightrange = indexshift([1:height1...],-0.5)
# 	ax1.yticks = (heightrange, labelshow[])
# 	on(labelshow) do ls
# 		ax1.yticks = (heightrange, ls)
# 	end
# 	ax1.xticks = (widthrange, numsshow[])
# 	on(numsshow) do ns
# 		ax1.xticks = (widthrange, ns)
# 	end
# 	ax1.xticklabelsize = 9
# 	ax1.yticklabelsize = 13
# 	ax1.xzoomlock[] = true
# 	ax1.yzoomlock[] = true
# 	axisaspect = 2.3
# 	ax1.yticklabelspace[] = 10
#
# 	poly!(ax1, [FRect2D(x, y, 1, 1) for x in 0:(width1-1) for y in 0:(height1-1)],
# 		 	color = :transparent, strokecolor = :black, strokewidth = 1)
#
# 	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
# 	charvec = @lift SplitApplyCombine.flatten($charshow)
# 	scatter!(ax1,
# 	        points1,
# 	        marker = charvec,
# 	        markersize = (10.0,11.0),
# 			color = :black,
# 			strokecolor = :black
# 	        )
# 	heatmap!(ax1, msashow, show_grid = true, show_axis = true,
# 	       colormap = colorscheme
#            )
#     ax1.attributes.xaxisposition[] = :top
#     deregister_interaction!(fig.current_axis.x,:rectanglezoom)
# 	return fig
# end
"""
    viewmsa(msa)

Create and return a Makie Figure for a fasta file.
# Examples
```julia
vm = viewmsa("data/fasta1.fas")
```
Parameters:
sheetsize ----- Dimensions of the msa shown, Default - [18,18]
resolution ---- Default - (1500, 600)
colorscheme --- Default - :viridis
positions ----- Residue positions, Default - length of msa
"""
function viewmsa(   msa::Vector{Tuple{String,String}};
					sheetsize = [20,40],
					resolution = (1500, 600),
                    colorscheme = :viridis,
                    colorval = 2,
                    positions = 0
				)
    #
    if positions == 0
        positions = [1:length(msa[1][2])...]
    end
    f2 = [msa[i][2] for i in 1:size(msa,1)]
    mat = [[f2[i]...] for i in 1:size(f2,1)] |> combinedims .|> string |> _t
    if size(mat,1) < sheetsize[1]
        height1 = size(mat,1) - 1
    else
        height1 = sheetsize[1]
    end
    if size(mat,2) < sheetsize[2]
        width1 = size(mat,2) - 1
    else
        width1 = sheetsize[2]
    end

    fig = Figure(resolution = resolution)
    ax1 = Axis(fig[1:7,3:9])
    tightlimits!(ax1)
    labels = Node([msa[i][1] for i in 1:size(msa,1)])
    nums = Node(positions)
    labelssize = @lift size($labels,1) - (height1-1)
    labelsrange = @lift $labelssize:-1:1
    numssize = @lift size($nums,1) - (width1-1)
    numsrange = @lift 1:1:$numssize

    sl1 = Slider(fig[end+1,3:9], range = numsrange, startvalue = 1)
    sl1.value = 1
    sl2 = Slider(fig[1:7,10], range = labelsrange, startvalue = 1, horizontal = false,
    	tellwidth = true, height = nothing)
    sl2.value = 1
    colorval = Node(colorval)
    strmsa = mat
    strmsavals = [ kdict(i) for i in strmsa ]
    strmsavals2 = strmsavals |> combinedims
    labelshow = lift(X->labels[][(X+(height1-1):-1:X)],sl2.value)
    numsshow = lift(X->nums[][(X:1:X+(width1-1))],sl1.value)
    labelshow2 = lift(X->(X+(height1-1):-1:X),sl2.value)
    numsshow2 = lift(X->(X:1:X+(width1-1)),sl1.value)
    fixtmsa = lift(X->replace(strmsavals2[X,:,:], nothing => 0.0),colorval)
    msashow = @lift $fixtmsa[$labelshow2,$numsshow2] |> _t
    charmsa = [x[1] for x in strmsa]
    charshow = @lift charmsa[$labelshow2,$numsshow2]
    widthrange = indexshift([1:width1...],-0.5)
    heightrange = indexshift([1:height1...],-0.5)
    ax1.yticks = (heightrange, labelshow[])
    on(labelshow) do ls
    	ax1.yticks = (heightrange, ls)
    end
    ax1.xticks = (widthrange, numsshow[])
    on(numsshow) do ns
    	ax1.xticks = (widthrange, ns)
    end
    ax1.xticklabelsize = 9
    ax1.yticklabelsize = 13
    ax1.xzoomlock[] = true
    ax1.yzoomlock[] = true
    axisaspect = 2.3
    ax1.yticklabelspace[] = 10

    poly!(ax1, [FRect2D(x, y, 1, 1) for x in 0:(width1-1) for y in 0:(height1-1)],
    	 	color = :transparent, strokecolor = :black, strokewidth = 1)

    points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
    charvec = @lift SplitApplyCombine.flatten($charshow)

    scatter!(ax1,
            points1,
            marker = charvec,
            markersize = (10.0,11.0),
    		color = :black,
    		strokecolor = :black
            )
    heatmap!(ax1, msashow, show_grid = true, show_axis = true,
           colormap = colorscheme
           )
    ax1.attributes.xaxisposition[] = :top
    deregister_interaction!(fig.current_axis.x,:rectanglezoom)
    return fig
end
