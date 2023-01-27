export getplottingdata,
       msavalues,
       plotmsa!,
       plotmsa

"""
	getplottingdata( msa )::Tuple{Matrix{String}, Vector{String}, Vector{String}}

Collects data for plotting (residue string matrix, x labels, and y labels).

This function converts an AbstractMultipleSequenceAlignment (from MIToS.MSA), or 
a Vector{Tuple{String,String}} (from FastaIO), or a Vector{FASTX.FASTA.Record} 
to a matrix of residue characters, x labels, and y labels.
"""
function getplottingdata(msa)
	# For MIToS MSAs
	if msa isa MSA.AbstractMultipleSequenceAlignment
        ylabels = keys(msa.matrix.dicts[1]) |> collect
	    xlabels = keys(msa.matrix.dicts[2]) |> collect
        msamatrix = Matrix(msa) .|> string

	# For fasta files loaded with FastaIO
    elseif msa isa Vector{Tuple{String,String}}
        ylabels = [msa[i][1] for i in 1:size(msa,1)]
	    xlabels = [1:length(msa[1][2])...] |> collect .|> string
        msamatrix = [[msa[i][2]...] for i in 1:size(msa,1)] |> combinedims .|> string
		@cast msamatrix[i,j] := msamatrix[j,i]
		msamatrix = msamatrix[:,:]

	# For fasta files loaded with FASTX
	elseif msa isa Vector{FASTX.FASTA.Record}
		ylabels = [identifier(msa[i]) for i in 1:size(msa,1)]
		xlabels = [1:length(msa)...] |> collect .|> string
		msamatrix = [[sequence(msa[i])...] for i in 1:size(msa,1)] |> combinedims .|> string
		@cast msamatrix[i,j] := msamatrix[j,i]
		msamatrix = msamatrix[:,:]
    else
        error("sorry methods for that input don't exist yet")
    end

	return msamatrix, xlabels, ylabels
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
    plotmsa!( fig, msa, msavalues )

Plot a multiple sequence alignment (MSA) into a Figure. 

# Example
```julia
fig = Figure(resolution = (1100, 400))

plotmsa!( fig::Figure, msamatrix::Matrix{String}, matrixvals::Matrix{Float32},
			xlabels::Vector{String}, 	
			ylabels::Vector{String};
			kwargs... )
```

### Optional Arguments:
- xlabels ------- {1:height}
- ylabels ------- {1:width}
- sheetsize ----- [40,20]
- gridposition -- (1,1)
- markersize ---- 12
- colorscheme --- :buda
- markercolor --- :black
- kwargs...   					# forwarded to scatter plot
"""
function plotmsa!( fig::Figure, msamatrix::Observable, matrixvals::Observable, 
				   xlabels = Observable(nothing), ylabels = Observable(nothing);	# row/column indices by default
				   sheetsize = [40,20],
				   gridposition = (1,1:3),
				   colorscheme = :buda,
				   markersize = 12,
				   markercolor = :black,
				   kwargs... )

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
function plotmsa!(fig, msamatrix, matrixvals, xlabels, ylabels; resolution = (1100, 400), kwargs...)
	if !(typeof(msamatrix) <:Observable)
		msamatrix = Observable(msamatrix)
	end
	if !(typeof(matrixvals) <:Observable)
		matrixvals = Observable(matrixvals)
	end
	if !(typeof(xlabels) <:Observable)
		xlabels = Observable(xlabels)
	end
	if !(typeof(ylabels) <:Observable)
		ylabels = Observable(ylabels)
	end

	plotmsa!(fig, msamatrix, matrixvals, xlabels, ylabels; kwargs...)
end
function plotmsa!(msamatrix, matrixvals, xlabels, ylabels; resolution = (1100, 400), kwargs...)
	fig = Figure(resolution = resolution)

	if !(typeof(msamatrix) <:Observable)
		msamatrix = Observable(msamatrix)
	end
	if !(typeof(matrixvals) <:Observable)
		matrixvals = Observable(matrixvals)
	end
	if !(typeof(xlabels) <:Observable)
		xlabels = Observable(xlabels)
	end
	if !(typeof(ylabels) <:Observable)
		ylabels = Observable(ylabels)
	end

	plotmsa!(fig, msamatrix, matrixvals, xlabels, ylabels; kwargs...)
end

"""
    plotmsa( msa )

Plot a multiple sequence alignment (MSA). Returns a Figure, or
a Figure and Observables for interaction. 

# Examples
```julia
downloadpfam("PF00062")
msa = MIToS.MSA.read("PF00062.stockholm.gz", Stockholm, 
					generatemapping =true, useidcoordinates=true)

plotmsa( msa; kwargs... )
```

### Optional Arguments:
- resolution -------- (1100, 400)
- sheetsize --------- [40,20]
- gridposition ------ (1,1)
- colorscheme ------- :viridis
- resdict ----------- kideradict    # Dictionary of values (::Dict{String,Float}, "Y" => 1.48) for heatmap.
- kf ---------------- 2             # If resdict == kideradict, this is the Kidera Factor. KF2 is size/volume-related.
- kwargs...    						# forwarded to scatter plot
"""
function plotmsa(msa; kwargs...)
	if typeof(msa) <:Observable
		msamatrix, xlabels, ylabels = getplottingdata(msa) .|> Observable
		matrixvals = @lift msavalues($msamatrix, resdict; kf = kf)
	else
		msa = Observable(msa)
		msamatrix, xlabels, ylabels = getplottingdata(msa) .|> Observable
		matrixvals = @lift msavalues($msamatrix, resdict; kf = kf)
	end
	plotmsa(msamatrix, matrixvals, xlabels, ylabels; kwargs...)
end

"""
    plotmsa( msa, msavalues )

Plot a multiple sequence alignment (MSA). Returns a Figure, or
a Figure and Observables for interaction.

# Examples
```julia
using MIToS.MSA
downloadpfam("PF00062")
msa = MIToS.MSA.read("PF00062.stockholm.gz", Stockholm, 
					generatemapping =true, useidcoordinates=true)
msamatrix, xlabels, ylabels = getplottingdata(msa) .|> Observable			
matrixvals = msavalues(msamatrix[]) |> Observable

plotmsa( msa, matrixvals; kwargs... )
```

### Optional Arguments:
- resolution -------- (1100, 400)
- sheetsize --------- [40,20]
- gridposition ------ (1,1)
- colorscheme ------- :viridis
- kwargs...    						# forwarded to scatter plot
"""
function plotmsa(msa, matrixvals; kwargs...)
	msamatrix, xlabels, ylabels = getplottingdata(msa) .|> Observable
	plotmsa(msamatrix, matrixvals, xlabels, ylabels; kwargs...)
end

"""
	plotmsa( fig, msamatrix, msavalues, xlabels, ylabels )

Plot a multiple sequence alignment (MSA) on a Figure. 

"""
function plotmsa(msamatrix, matrixvals, xlabels, ylabels; resolution = (1100, 400), kwargs...)
	fig = Figure(resolution = resolution)

	if !(typeof(msamatrix) <:Observable)
		msamatrix = Observable(msamatrix)
	end
	if !(typeof(matrixvals) <:Observable)
		matrixvals = Observable(matrixvals)
	end
	if !(typeof(xlabels) <:Observable)
		xlabels = Observable(xlabels)
	end
	if !(typeof(ylabels) <:Observable)
		ylabels = Observable(ylabels)
	end

	plotmsa!(fig, msamatrix, matrixvals, xlabels, ylabels; kwargs...)
end
