export plottingdata,
       msavalues,
       plotmsa!,
       plotmsa

"""
	plottingdata( msa )

Collects data for plotting (residue string matrix, matrix heatmap values,
x labels, and y labels) from a multiple sequence alignment (MSA) object.

The MSA object can be a:
- `AbstractMultipleSequenceAlignment` from MIToS.MSA,
- vector of tuples 'Vector{Tuple{String,String}}' from FastaIO,
- vector of FASTA records 'Vector{FASTX.FASTA.Record}' from FASTX.
"""
function plottingdata(msa::Observable{T}) where {T<:MSA.AbstractMultipleSequenceAlignment}
	ylabels = @lift keys($msa.matrix.dicts[1]) |> collect
	xlabels = @lift [1:size($msa.matrix.array,2)...] |> collect .|> string
	msamatrix = @lift Matrix($msa) .|> string
	matrixvals = @lift msavalues($msamatrix)
	selected = Observable("None")

    return OrderedDict(:matrix => msamatrix,
                        :xlabels => xlabels,
                        :ylabels => ylabels,
						:matrixvals => matrixvals,
						:selected => selected)
end
function plottingdata(msa::Observable{T}) where {T<:Vector{Tuple{String,String}}}
	ylabels = @lift [$msa[i][1] for i in 1:size($msa,1)]
	xlabels = @lift [1:length($msa[1][2])...] |> collect .|> string
	msamatrix = @lift [[$msa[i][2]...] for i in 1:size($msa,1)] |> combinedims .|> string
	msamatrixtemp = msamatrix[]
	@cast msamatrixtemp[i,j] := msamatrixtemp[j,i]
	msamatrixtemp = msamatrixtemp[:,:]
	msamatrix[] = msamatrixtemp
	matrixvals = @lift msavalues($msamatrix)
	selected = Observable("None")

    return OrderedDict(:matrix => msamatrix,
                        :xlabels => xlabels,
                        :ylabels => ylabels,
						:matrixvals => matrixvals,
						:selected => selected)
end
function plottingdata(msa::Observable{T}) where {T<:Vector{FASTX.FASTA.Record}}
	ylabels = @lift [identifier($msa[i]) for i in 1:size($msa,1)]
	xlabels = @lift [1:length($msa)...] |> collect .|> string
	msamatrix = @lift [[sequence($msa[i])...] for i in 1:size($msa,1)] |> combinedims .|> string
	msamatrixtemp = msamatrix[]
	@cast msamatrixtemp[i,j] := msamatrixtemp[j,i]
	msamatrixtemp = msamatrixtemp[:,:]
	msamatrix[] = msamatrixtemp
	matrixvals = @lift msavalues($msamatrix)
	selected = Observable("None")

    return OrderedDict(:matrix => msamatrix,
                        :xlabels => xlabels,
                        :ylabels => ylabels,
						:matrixvals => matrixvals,
						:selected => selected)
end
function plottingdata(msa::T) where {T<:Union{Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record},
											   MSA.AbstractMultipleSequenceAlignment}}
	return plottingdata(Observable(msa))
end

"""
	msavalues( msa::AbstractMatrix, resdict::AbstractDict )::Matrix{Real}

Returns a matrix of numbers according to the given dictionary,
where keys are residue letters and values are numbers. This matrix
is used as input for `plotmsa` for the heatmap colors of the residue
positions.

Default values for residue letters are from Kidera Factor values.
From:
Kenta Nakai, Akinori Kidera, Minoru Kanehisa, Cluster analysis of amino acid indices
for prediction of protein structure and function, Protein Engineering, Design and Selection,
Volume 2, Issue 2, July 1988, Pages 93–100, https://doi.org/10.1093/protein/2.2.93

kf 2 is Kidera Factor 2 (size/volume-related). The KF dictionary is in `utils.jl`, or
you can look at the `kideradict` variable.

### Keyword Arguments:
- resdict ------- kideradict by default, alternatively give a Dict{String,Vector{Float}}
- kf ------------ 2 by default, alternatively give an integer from 1:10
"""
function msavalues(msamatrix::AbstractMatrix, resdict = kideradict; kf = 2)
	matrixvals = []

	if resdict == kideradict
		matrixvals = [ Float32(resdict[i][kf]) for i in msamatrix ]
	else
		matrixvals = [ Float32(resdict[i]) for i in msamatrix ]
	end

	return matrixvals
end

"""
    plotmsa!( fig, msa )

Plot a multiple sequence alignment (MSA) into a Figure.

# Example
```julia
fig = Figure(size = (1100, 400))

plotmsa!( fig::Figure, msa::T; kwargs... ) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
```

### Keyword Arguments:
- sheetsize ----- [40,20]
- gridposition -- (1,1)
- markersize ---- 12
- colorscheme --- :buda
- markercolor --- :black
- xticklabelsize - 11
- yticklabelsize - 11
- size ----- (700,300)
- kwargs...   					# forwarded to scatter plot
"""
function plotmsa!( fig::Figure, msa::Observable{T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   xticklabelsize = 11,
				   yticklabelsize = 11,
				   size = (700,300),
				   kwargs... ) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
	#
	plotdata = plottingdata(msa)
	msamatrix = plotdata[:matrix]
	xlabels = plotdata[:xlabels]
	ylabels = plotdata[:ylabels]
	matrixvals = plotdata[:matrixvals]
	selected = plotdata[:selected]

	grid1 = fig[gridposition...] = GridLayout(size)
	ax = Axis(grid1[1:7,3:9]; height = 275, width = 700)

	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:Base.size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:Base.size($matrixvals,1))
	end

	ylabelsize =  @lift Base.size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift Base.size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = 700)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 275)
	sl2.value[] = 1

	ylabelshow = lift(X->ylabels[][(X+(height1-1):-1:X)],sl2.value)	# currently shown y labels, updated with vertical right slider (sl2)
	xlabelshow = lift(X->xlabels[][(X:1:X+(width1-1))],sl1.value)	# corresponding x labels, updated with horizontal bottom slider (sl1)
	ylabelshowindex = lift(X->(X+(height1-1):-1:X), sl2.value)
	xlabelshowindex = lift(X->(X:1:X+(width1-1)), sl1.value)

	colorvals = @lift $matrixvals[$ylabelshowindex, $xlabelshowindex] |> transpose |> collect
	charmsa = @lift [x[1] for x in $msamatrix]
	charshow = @lift $charmsa[$ylabelshowindex, $xlabelshowindex]

	ax.yticks = (heightrange, ylabelshow[])
	on(ylabelshow) do ls
		ax.yticks = (heightrange, ls)
	end
	ax.xticks = ([1:width1...], xlabelshow[])
	on(xlabelshow) do ns
		ax.xticks = ([1:width1...], ns)
	end
	ax.xticklabelsize[] = xticklabelsize
	ax.yticklabelsize[] = yticklabelsize
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0

	points1 = [Point2f(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true,
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n" *
				"$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 " *
				"value: $(colorvals[][Int64(p[1]),Int64(p[2])])",
			kwargs...
	)
	hl = hlines!(ax,
		.-(heightrange, 0.5),
		color = :black
	)
	vl = vlines!(ax,
		.-(widthrange, 0.5),
		color = :black
	)
	hm.inspectable[] = false
	sc.inspectable[] = true
	hl.inspectable[] = false
	vl.inspectable[] = false

	ax.xgridvisible = true
	ax.xaxisposition[] = :top
	ax.xticklabelrotation[] = 1f0
	deregister_interaction!(fig.current_axis.x,:rectanglezoom)
	DataInspector(ax)

	selectedidx = Observable(-1)
	selectionlines = @lift $selectedidx == -1 ? Vector{Float64}(undef,0) : [$selectedidx-0.5,$selectedidx+0.5]
	showncols = @lift $(fig.content[1].xticks)[2]
	showncols[]
	on(showncols) do scols
		if selected[] in scols
			selectedidx[] = findfirst(x->x==selected[],scols)
			selectionlines[] = [selectedidx[]-0.5,selectedidx[]+0.5]
		else
			selectedidx[] = -1
		end
	end

	xx = vlines!(fig.content[1], selectionlines; color = :blue, linewidth = 4, inspectable = false)
	xx2 = vlines!(fig.content[1], selectionlines; color = :cyan, linewidth = 3, inspectable = false)

	mouseevents = addmouseevents!(fig.content[1].scene, fig.content[1].scene.plots[2]; priority = 1)
	onmouseleftclick(mouseevents) do event
		picked = mouse_selection(fig.content[1].scene)
		selectedplace = [picked...][2]
		selectedidx[] = div(selectedplace,height1[])+1
		selected[] = showncols[][selectedidx[]]
	end

	display(fig)
	fig
end
function plotmsa!( figposition::GridPosition, msa::Observable{T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   xticklabelsize = 11,
				   yticklabelsize = 11,
				   size = (700,300),
				   kwargs... ) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
	#
	plotdata = plottingdata(msa)
	msamatrix = plotdata[:matrix]
	xlabels = plotdata[:xlabels]
	ylabels = plotdata[:ylabels]
	matrixvals = plotdata[:matrixvals]
	selected = plotdata[:selected]

	grid1 = fig[gridposition...] = GridLayout(size)
	ax = Axis(grid1[1:7,3:9]; height = (size[2] * 23) ÷ 24, width = size[1])

	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:Base.size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:Base.size($matrixvals,1))
	end

	ylabelsize =  @lift Base.size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift Base.size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = size[2])
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 275)
	sl2.value[] = 1

	ylabelshow = lift(X->ylabels[][(X+(height1-1):-1:X)],sl2.value)	# currently shown y labels, updated with vertical right slider (sl2)
	xlabelshow = lift(X->xlabels[][(X:1:X+(width1-1))],sl1.value)	# corresponding x labels, updated with horizontal bottom slider (sl1)
	ylabelshowindex = lift(X->(X+(height1-1):-1:X), sl2.value)
	xlabelshowindex = lift(X->(X:1:X+(width1-1)), sl1.value)

	colorvals = @lift $matrixvals[$ylabelshowindex, $xlabelshowindex] |> transpose |> collect
	charmsa = @lift [x[1] for x in $msamatrix]
	charshow = @lift $charmsa[$ylabelshowindex, $xlabelshowindex]

	ax.yticks = (heightrange, ylabelshow[])
	on(ylabelshow) do ls
		ax.yticks = (heightrange, ls)
	end
	ax.xticks = ([1:width1...], xlabelshow[])
	on(xlabelshow) do ns
		ax.xticks = ([1:width1...], ns)
	end
	ax.xticklabelsize[] = xticklabelsize
	ax.yticklabelsize[] = yticklabelsize
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0

	points1 = [Point2f(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true,
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n" *
				"$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 " *
				"value: $(colorvals[][Int64(p[1]),Int64(p[2])])",
			kwargs...
	)
	hl = hlines!(ax,
		.-(heightrange, 0.5),
		color = :black
	)
	vl = vlines!(ax,
		.-(widthrange, 0.5),
		color = :black
	)
	hm.inspectable[] = false
	sc.inspectable[] = true
	hl.inspectable[] = false
	vl.inspectable[] = false

	ax.xgridvisible = true
	ax.xaxisposition[] = :top
	ax.xticklabelrotation[] = 1f0
	deregister_interaction!(fig.current_axis.x,:rectanglezoom)
	DataInspector(ax)

	selectedidx = Observable(-1)
	selectionlines = @lift $selectedidx == -1 ? Vector{Float64}(undef,0) : [$selectedidx-0.5,$selectedidx+0.5]
	showncols = @lift $(fig.content[1].xticks)[2]
	showncols[]
	on(showncols) do scols
		if selected[] in scols
			selectedidx[] = findfirst(x->x==selected[],scols)
			selectionlines[] = [selectedidx[]-0.5,selectedidx[]+0.5]
		else
			selectedidx[] = -1
		end
	end

	xx = vlines!(fig.content[1], selectionlines; color = :blue, linewidth = 4, inspectable = false)
	xx2 = vlines!(fig.content[1], selectionlines; color = :cyan, linewidth = 3, inspectable = false)

	mouseevents = addmouseevents!(fig.content[1].scene, fig.content[1].scene.plots[2]; priority = 1)
	onmouseleftclick(mouseevents) do event
		picked = mouse_selection(fig.content[1].scene)
		selectedplace = [picked...][2]
		selectedidx[] = div(selectedplace,height1[])+1
		selected[] = showncols[][selectedidx[]]
	end

	display(fig)
	fig
end
function plotmsa!( fig::Figure, plotdata::AbstractDict{Symbol,T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   xticklabelsize = 11,
				   yticklabelsize = 11,
				   size = (700,300),
				   kwargs... ) where {T<:Observable}
	#
	msamatrix = plotdata[:matrix]
	xlabels = plotdata[:xlabels]
	ylabels = plotdata[:ylabels]
	matrixvals = plotdata[:matrixvals]
	selected = plotdata[:selected]

	grid1 = fig[gridposition...] = GridLayout(size)
	ax = Axis(grid1[1:7,3:9]; height = 275, width = 700)

	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:Base.size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:Base.size($matrixvals,1))
	end

	ylabelsize =  @lift Base.size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift Base.size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = 700)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 275)
	sl2.value[] = 1

	ylabelshow = lift(X->ylabels[][(X+(height1-1):-1:X)],sl2.value)	# currently shown y labels, updated with vertical right slider (sl2)
	xlabelshow = lift(X->xlabels[][(X:1:X+(width1-1))],sl1.value)	# corresponding x labels, updated with horizontal bottom slider (sl1)
	ylabelshowindex = lift(X->(X+(height1-1):-1:X), sl2.value)
	xlabelshowindex = lift(X->(X:1:X+(width1-1)), sl1.value)

	colorvals = @lift $matrixvals[$ylabelshowindex, $xlabelshowindex] |> transpose |> collect
	charmsa = @lift [x[1] for x in $msamatrix]
	charshow = @lift $charmsa[$ylabelshowindex, $xlabelshowindex]

	ax.yticks = (heightrange, ylabelshow[])
	on(ylabelshow) do ls
		ax.yticks = (heightrange, ls)
	end
	ax.xticks = ([1:width1...], xlabelshow[])
	on(xlabelshow) do ns
		ax.xticks = ([1:width1...], ns)
	end
	ax.xticklabelsize[] = xticklabelsize
	ax.yticklabelsize[] = yticklabelsize
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0

	points1 = [Point2f(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true,
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n" *
				"$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 " *
				"value: $(colorvals[][Int64(p[1]),Int64(p[2])])",
			kwargs...
	)
	hl = hlines!(ax,
		.-(heightrange, 0.5),
		color = :black
	)
	vl = vlines!(ax,
		.-(widthrange, 0.5),
		color = :black
	)
	hm.inspectable[] = false
	sc.inspectable[] = true
	hl.inspectable[] = false
	vl.inspectable[] = false

	ax.xgridvisible = true
	ax.xaxisposition[] = :top
	ax.xticklabelrotation[] = 1f0
	deregister_interaction!(fig.current_axis.x,:rectanglezoom)
	DataInspector(ax)

	selectedidx = Observable(-1)
	selectionlines = @lift $selectedidx == -1 ? Vector{Float64}(undef,0) : [$selectedidx-0.5,$selectedidx+0.5]
	showncols = @lift $(fig.content[1].xticks)[2]
	showncols[]
	on(showncols) do scols
		if selected[] in scols
			selectedidx[] = findfirst(x->x==selected[],scols)
			selectionlines[] = [selectedidx[]-0.5,selectedidx[]+0.5]
		else
			selectedidx[] = -1
		end
	end

	xx = vlines!(fig.content[1], selectionlines; color = :blue, linewidth = 4, inspectable = false)
	xx2 = vlines!(fig.content[1], selectionlines; color = :cyan, linewidth = 3, inspectable = false)

	mouseevents = addmouseevents!(fig.content[1].scene, fig.content[1].scene.plots[2]; priority = 1)
	onmouseleftclick(mouseevents) do event
		picked = mouse_selection(fig.content[1].scene)
		selectedplace = [picked...][2]
		selectedidx[] = div(selectedplace,height1[])+1
		selected[] = showncols[][selectedidx[]]
	end

	display(fig)
	fig
end
function plotmsa!( figposition::GridPosition, plotdata::AbstractDict{Symbol,T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   xticklabelsize = 11,
				   yticklabelsize = 11,
				   size = (700,300),
				   kwargs... ) where {T}
	#
	msamatrix = plotdata[:matrix]
	xlabels = plotdata[:xlabels]
	ylabels = plotdata[:ylabels]
	matrixvals = plotdata[:matrixvals]
	selected = plotdata[:selected]

	grid1 = fig[gridposition...] = GridLayout(size = size)
	ax = Axis(grid1[1:7,3:9]; height = 275, width = 700)

	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:Base.size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:Base.size($matrixvals,1))
	end

	ylabelsize =  @lift Base.size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift Base.size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = 700)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 275)
	sl2.value[] = 1

	ylabelshow = lift(X->ylabels[][(X+(height1-1):-1:X)],sl2.value)	# currently shown y labels, updated with vertical right slider (sl2)
	xlabelshow = lift(X->xlabels[][(X:1:X+(width1-1))],sl1.value)	# corresponding x labels, updated with horizontal bottom slider (sl1)
	ylabelshowindex = lift(X->(X+(height1-1):-1:X), sl2.value)
	xlabelshowindex = lift(X->(X:1:X+(width1-1)), sl1.value)

	colorvals = @lift $matrixvals[$ylabelshowindex, $xlabelshowindex] |> transpose |> collect
	charmsa = @lift [x[1] for x in $msamatrix]
	charshow = @lift $charmsa[$ylabelshowindex, $xlabelshowindex]

	ax.yticks = (heightrange, ylabelshow[])
	on(ylabelshow) do ls
		ax.yticks = (heightrange, ls)
	end
	ax.xticks = ([1:width1...], xlabelshow[])
	on(xlabelshow) do ns
		ax.xticks = ([1:width1...], ns)
	end
	ax.xticklabelsize[] = xticklabelsize
	ax.yticklabelsize[] = yticklabelsize
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0

	points1 = [Point2f(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true,
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n" *
				"$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 " *
				"value: $(colorvals[][Int64(p[1]),Int64(p[2])])",
			kwargs...
	)
	hl = hlines!(ax,
		.-(heightrange, 0.5),
		color = :black
	)
	vl = vlines!(ax,
		.-(widthrange, 0.5),
		color = :black
	)
	hm.inspectable[] = false
	sc.inspectable[] = true
	hl.inspectable[] = false
	vl.inspectable[] = false

	ax.xgridvisible = true
	ax.xaxisposition[] = :top
	ax.xticklabelrotation[] = 1f0
	deregister_interaction!(fig.current_axis.x,:rectanglezoom)
	DataInspector(ax)

	selectedidx = Observable(-1)
	selectionlines = @lift $selectedidx == -1 ? Vector{Float64}(undef,0) : [$selectedidx-0.5,$selectedidx+0.5]
	showncols = @lift $(fig.content[1].xticks)[2]
	showncols[]
	on(showncols) do scols
		if selected[] in scols
			selectedidx[] = findfirst(x->x==selected[],scols)
			selectionlines[] = [selectedidx[]-0.5,selectedidx[]+0.5]
		else
			selectedidx[] = -1
		end
	end

	xx = vlines!(fig.content[1], selectionlines; color = :blue, linewidth = 4, inspectable = false)
	xx2 = vlines!(fig.content[1], selectionlines; color = :cyan, linewidth = 3, inspectable = false)

	mouseevents = addmouseevents!(fig.content[1].scene, fig.content[1].scene.plots[2]; priority = 1)
	onmouseleftclick(mouseevents) do event
		picked = mouse_selection(fig.content[1].scene)
		selectedplace = [picked...][2]
		selectedidx[] = div(selectedplace,height1[])+1
		selected[] = showncols[][selectedidx[]]
	end

	display(fig)
	fig
end
function plotmsa!(fig::Figure, msa::T; kwargs...) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
    msaobs = Observable(msa)
    plotmsa!(fig, msaobs; kwargs...)
end
function plotmsa!(figposition::GridPosition, msa::T; kwargs...) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
    msaobs = Observable(msa)
    plotmsa!(figposition, msaobs; kwargs...)
end

"""
    plotmsa( msa )
	plotmsa( plotdata )

Plot a multiple sequence alignment (MSA). Returns a Figure, or
a Figure and Observables for interaction.

# Examples
```julia
MIToS.Pfam.downloadpfam("PF00062")	# download PF00062 MSA
msa = MIToS.MSA.read_file("PF00062.stockholm.gz", Stockholm,
	generatemapping =true, useidcoordinates=true)

plotmsa( msa; kwargs... )
```

### Keyword Arguments:
- figsize ----- (1000,350)	# because `size` applies to the MSA plot
- sheetsize --------- [40,20]
- gridposition ------ (1,1:3)
- colorscheme ------- :buda
- markersize -------- 12
- markercolor ------- :black
- xticklabelsize ---- 11
- yticklabelsize ---- 11
- kwargs...    						# forwarded to scatter plot
"""
function plotmsa(msa; figsize = (1000,350), kwargs...)
	fig = Figure(size = figsize)
	plotmsa!(fig, Observable(msa); kwargs...)
end
function plotmsa(msa::Observable; figsize = (1000,350), kwargs...)
	fig = Figure(size = figsize)
	plotmsa!(fig, msa; kwargs...)
end
function plotmsa(plotdata::T; figsize = (1000,350), kwargs...) where {T<:AbstractDict}
	fig = Figure(size = figsize)
	plotmsa!(fig, plotdata; kwargs...)
end
