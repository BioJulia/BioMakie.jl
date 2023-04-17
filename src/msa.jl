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
function plottingdata(msa::MSA.AbstractMultipleSequenceAlignment)
	ylabels = keys(msa.matrix.dicts[1]) |> collect
	xlabels = keys(msa.matrix.dicts[2]) |> collect
	msamatrix = Matrix(msa) .|> string
	matrixvals = msavalues(msamatrix)

    return OrderedDict("matrix" => msamatrix, 
                        "xlabels" => xlabels, 
                        "ylabels" => ylabels,
						"matrixvals" => matrixvals)
end
function plottingdata(msa::Observable{T}) where {T<:MSA.AbstractMultipleSequenceAlignment}
	ylabels = @lift keys($msa.matrix.dicts[1]) |> collect
	xlabels = @lift keys($msa.matrix.dicts[2]) |> collect
	msamatrix = @lift Matrix($msa) .|> string
	matrixvals = @lift msavalues($msamatrix)

    return OrderedDict("matrix" => msamatrix, 
                        "xlabels" => xlabels, 
                        "ylabels" => ylabels,
						"matrixvals" => matrixvals)
end
function plottingdata(msa::Vector{Tuple{String,String}})
	ylabels = [msa[i][1] for i in 1:size(msa,1)]
	xlabels = [1:length(msa[1][2])...] |> collect .|> string
	msamatrix = [[msa[i][2]...] for i in 1:size(msa,1)] |> combinedims .|> string
	@cast msamatrix[i,j] := msamatrix[j,i]
	msamatrix = msamatrix[:,:]
	matrixvals = msavalues(msamatrix)

    return OrderedDict("matrix" => msamatrix, 
                        "xlabels" => xlabels, 
                        "ylabels" => ylabels,
						"matrixvals" => matrixvals)
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

    return OrderedDict("matrix" => msamatrix, 
                        "xlabels" => xlabels, 
                        "ylabels" => ylabels,
						"matrixvals" => matrixvals)
end
function plottingdata(msa::Vector{FASTX.FASTA.Record})
	ylabels = [identifier(msa[i]) for i in 1:size(msa,1)]
	xlabels = [1:length(msa)...] |> collect .|> string
	msamatrix = [[sequence(msa[i])...] for i in 1:size(msa,1)] |> combinedims .|> string
	@cast msamatrix[i,j] := msamatrix[j,i]
	msamatrix = msamatrix[:,:]
	matrixvals = msavalues(msamatrix)

    return OrderedDict("matrix" => msamatrix, 
                        "xlabels" => xlabels, 
                        "ylabels" => ylabels,
						"matrixvals" => matrixvals)
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

    return OrderedDict("matrix" => msamatrix, 
                        "xlabels" => xlabels, 
                        "ylabels" => ylabels,
						"matrixvals" => matrixvals)
end

"""
	msavalues( msa::AbstractMatrix, resdict::AbstractDict )::Matrix{Real}

Returns a matrix of numbers according to the given dictionary,
where keys are residue letters and values are numbers. This matrix
is used as input for `plotmsa` for the heatmap colors.

Default values for residue letters are from Kidera Factor values. 
kf 2 is Kidera Factor 2 (size/volume-related). The KF dictionary is in `utils.jl`.
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
fig = Figure(resolution = (1100, 400))

plotmsa!( fig::Figure, msa::T; kwargs... ) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
```

### Keyword Arguments:
- xlabels ------- {1:height}
- ylabels ------- {1:width}
- sheetsize ----- [40,20]
- gridposition -- (1,1)
- markersize ---- 12
- colorscheme --- :buda
- markercolor --- :black
- kwargs...   					# forwarded to scatter plot
"""
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
function plotmsa!( fig::Figure, msa::Observable{T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   kwargs... ) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
	#
	plotdata = @lift plottingdata($msa)
	msamatrix = @lift $plotdata["matrix"]
	xlabels = @lift $plotdata["xlabels"]
	ylabels = @lift $plotdata["ylabels"]
	matrixvals = @lift $plotdata["matrixvals"]

	grid1 = fig[gridposition...] = GridLayout(resolution = (1100,400))
	ax = Axis(grid1[1:7,3:9]; height = 300, width = 800)
	
	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:size($matrixvals,1))
	end

	ylabelsize =  @lift size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = 800)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 300)
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
	ax.xticklabelsize = 11
	ax.yticklabelsize = 11
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0
	
	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true, 
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 value: $(colorvals[][Int64.(p)...])",
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
	display(fig)
	fig
end
function plotmsa!( figposition::GridPosition, msa::Observable{T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   kwargs... ) where {T<:Union{MSA.AbstractMultipleSequenceAlignment,
											   Vector{Tuple{String,String}},
											   Vector{FASTX.FASTA.Record}}}
	#
	plotdata = @lift plottingdata($msa)
	msamatrix = @lift $plotdata["matrix"]
	xlabels = @lift $plotdata["xlabels"]
	ylabels = @lift $plotdata["ylabels"]
	matrixvals = @lift $plotdata["matrixvals"]

	grid1 = figposition = GridLayout(resolution = (1100,400))
	ax = Axis(grid1[1:7,3:9]; height = 300, width = 800)
	
	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:size($matrixvals,1))
	end

	ylabelsize =  @lift size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = 800)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 300)
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
	ax.xticklabelsize = 11
	ax.yticklabelsize = 11
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0
	
	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true, 
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 value: $(colorvals[][Int64.(p)...])",
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
	display(fig)
	fig
end
function plotmsa!( fig::Figure, plotdata::AbstractDict{String,T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   kwargs... ) where {T}
	#
	msamatrix = []
	xlabels = []
	ylabels = []
	matrixvals = []
	
	if T<:Observable
		msamatrix = plotdata["matrix"]
		xlabels = plotdata["xlabels"]
		ylabels = plotdata["ylabels"]
		matrixvals = plotdata["matrixvals"]
	else
		msamatrix = plotdata["matrix"] |> Observable
		xlabels = plotdata["xlabels"] |> Observable
		ylabels = plotdata["ylabels"] |> Observable
		matrixvals = plotdata["matrixvals"] |> Observable
	end

	grid1 = fig[gridposition...] = GridLayout(resolution = (1100,400))
	ax = Axis(grid1[1:7,3:9]; height = 300, width = 800)
	
	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:size($matrixvals,1))
	end

	ylabelsize =  @lift size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = 800)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 300)
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
	ax.xticklabelsize = 11
	ax.yticklabelsize = 11
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0
	
	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true, 
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 value: $(colorvals[][Int64.(p)...])",
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
	display(fig)
	fig
end
function plotmsa!( figposition::GridPosition, plotdata::AbstractDict{String,T};
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   kwargs... ) where {T}
	#
	msamatrix = []
	xlabels = []
	ylabels = []
	matrixvals = []
	
	if T<:Observable
		msamatrix = plotdata["matrix"]
		xlabels = plotdata["xlabels"]
		ylabels = plotdata["ylabels"]
		matrixvals = plotdata["matrixvals"]
	else
		msamatrix = plotdata["matrix"] |> Observable
		xlabels = plotdata["xlabels"] |> Observable
		ylabels = plotdata["ylabels"] |> Observable
		matrixvals = plotdata["matrixvals"] |> Observable
	end

	grid1 = figposition = GridLayout(resolution = (1100,400))
	ax = Axis(grid1[1:7,3:9]; height = 300, width = 800)
	
	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels[] == nothing
		xlabels = @lift string.(1:size($matrixvals,2))
	end
	if ylabels[] == nothing
		ylabels = @lift string.(1:size($matrixvals,1))
	end

	ylabelsize =  @lift size($ylabels,1) - (height1-1)
	ylabelrange = @lift $ylabelsize:-1:1
	xlabelsize =  @lift size($xlabels,1) - (width1-1)
	xlabelrange = @lift 1:1:$xlabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = xlabelrange, startvalue = 1, width = 800)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = ylabelrange, startvalue = 1, horizontal = false,
		height = 300)
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
	ax.xticklabelsize = 11
	ax.yticklabelsize = 11
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10.0
	
	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	hm = heatmap!(ax, colorvals, show_grid = true, 
			colormap = colorscheme,
	)
	sc = scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			inspector_label = (self, i, p) -> "$(ylabelshow[][Int64(p[2])])\n$(resletterdict[string(charvec[][i])])  $(xlabelshow[][Int64(p[1])]) 	 value: $(colorvals[][Int64.(p)...])",
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
	display(fig)
	fig
end

"""
    plotmsa( msa )
	plotmsa( plotdata )

Plot a multiple sequence alignment (MSA). Returns a Figure, or
a Figure and Observables for interaction. 

# Examples
```julia
downloadpfam("PF00062")
msa = MIToS.MSA.read("PF00062.stockholm.gz", Stockholm, 
					generatemapping =true, useidcoordinates=true)

plotmsa( msa; kwargs... )
```

### Keyword Arguments:
- resolution -------- (1100, 400)
- sheetsize --------- [40,20]
- gridposition ------ (1,1)
- colorscheme ------- :viridis
- resdict ----------- kideradict    # Dictionary of values (::Dict{String,Float}, "Y" => 1.48) for heatmap.
- kf ---------------- 2             # If resdict == kideradict, this is the Kidera Factor. KF2 is size/volume-related.
- kwargs...    						# forwarded to scatter plot
"""
function plotmsa(msa; kwargs...)
	fig = Figure()
	plotmsa!(fig, Observable(msa); kwargs...)
end
function plotmsa(msa::Observable; kwargs...)
	fig = Figure()
	plotmsa!(fig, msa; kwargs...)
end
function plotmsa(plotdata::T; kwargs...) where {T<:AbstractDict}
	fig = Figure()
	plotmsa!(fig, plotdata; kwargs...)
end
