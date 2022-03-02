"""
    viewmsa(msa)

Create and return a Makie Figure for a AbstractMultipleSequenceAlignment.
# Examples
```julia
using MIToS.MSA
downloadpfam("pf00062")
vm = MIToS.MSA.read("pf00062.stockholm.gz",Stockholm) |> Observable
fig1 = viewmsa(vm)

using FastaIO
vm = FastaIO.readfasta("data/fasta1.fas") |> Observable
fig1 = viewmsa(vm)
```
Parameters:
sheetsize ----- Dimensions of the msa shown, Default - [40,20]
resolution ---- Default - (1500, 600)
colorscheme --- Default - :viridis
positions ----- Residue positions, Default - 1:(length of msa)
"""
function viewmsa(   msa::T;
					sheetsize = [40,20],
					resolution = (1500, 600),
                    colorscheme = :viridis,
                    colorval = 2,
                    positions = 0
				) where {T<:Observable}
	width1 = sheetsize[1]
	height1 = sheetsize[2]
	fig = Figure(resolution = resolution)
	ax = Axis(fig[1:7,3:9])
    labels = nothing
    nums = nothing
    strmsa = nothing
	tightlimits!(ax)
    # f2 = [msa[i][2] for i in 1:size(msa,1)]
    # mat = [[f2[i]...] for i in 1:size(f2,1)] |> combinedims .|> string |> _t
    # if size(mat,1) < sheetsize[1]
    #     height1 = size(mat,1) - 1
    # else
    #     height1 = sheetsize[1]
    # end
    # if size(mat,2) < sheetsize[2]
    #     width1 = size(mat,2) - 1
    # else
    #     width1 = sheetsize[2]
    # end
    if typeof(msa[])<:MSA.AbstractMultipleSequenceAlignment
        labels = @lift $(msa).matrix.dicts[1] |> keys |> collect
	    nums = @lift $(msa).matrix.dicts[2] |> keys |> collect
        strmsa = @lift Matrix($msa) .|> string
    elseif typeof(msa[])<:Vector{Tuple{String,String}}
        if positions == 0
            positions = @lift [1:length($msa[1][2])...]
        end
        labels = @lift [$msa[i][1] for i in 1:size($msa,1)]
	    nums = typeof(positions)<:Observable ? (@lift collect($positions)) : Observable(positions)
        strmsa = @lift [[$fas1[i][2]...] for i in 1:size($fas1,1)] |> combinedims .|> string
    else
        error("sorry methods for that input don't exist")
    end
	labelssize = @lift size($labels,1) - (height1-1)
	labelsrange = @lift $labelssize:-1:1
	numssize = @lift size($nums,1) - (width1-1)
	numsrange = @lift 1:1:$numssize
    sl1 = GLMakie.Slider(fig[end+1,3:9], range = numsrange, startvalue = 1)
	sl1.value = 1
	sl2 = GLMakie.Slider(fig[1:7,10], range = labelsrange, startvalue = 1, horizontal = false,
		tellwidth = true, height = nothing)
	sl2.value = labelssize[]
    colorval = typeof(colorval)<:Observable ? colorval : Observable(colorval)
	strmsavals = @lift [ _kdict(i) for i in $strmsa ]
	strmsavals2 = @lift $strmsavals |> combinedims
	labelshow = lift(X->labels[][(X+(height1-1):-1:X)],sl2.value)
	numsshow = lift(X->nums[][(X:1:X+(width1-1))],sl1.value)
	labelshow2 = lift(X->(X+(height1-1):-1:X),sl2.value)
	numsshow2 = lift(X->(X:1:X+(width1-1)),sl1.value)
	fixtmsa = @lift replace($strmsavals2[$colorval,:,:], nothing => 0.0)
	msashow = @lift $fixtmsa[$labelshow2,$numsshow2] |> _t
	charmsa = @lift [x[1] for x in $strmsa]
	charshow = @lift $charmsa[$labelshow2,$numsshow2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]
	ax.yticks = (heightrange, labelshow[])
	on(labelshow) do ls
		ax.yticks = (heightrange, ls)
	end
	ax.xticks = (widthrange, numsshow[])
	on(numsshow) do ns
		ax.xticks = (widthrange, ns)
	end
	ax.xticklabelsize = 9
	ax.yticklabelsize = 13
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10
	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)
	scatter!(ax,
	        points1,
	        marker = charvec,
	        markersize = (10.0,11.0),
			color = :black,
			strokecolor = :black
	        )
	heatmap!(ax, msashow, show_grid = true, show_axis = true,
	       colormap = colorscheme
           )
    ax.attributes.xaxisposition[] = :top
    deregister_interaction!(fig.current_axis.x,:rectanglezoom)
	return fig
end
