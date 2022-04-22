export getplottingdata,
       msavalues,
       plotmsa!,
       plotmsa

"""
	getplottingdata( msa )::Tuple{Matrix{String}, Vector{String}, Vector{String}}

Collects data for plotting (residue string matrix, x labels, and y labels).

This function converts an AbstractMultipleSequenceAlignment (from MIToS.MSA) or 
a Vector{Tuple{String,String}} (from FastaIO) to a matrix of residue characters, x labels, and y labels.
"""
function getplottingdata(msa)
	# For MIToS MSAs
	if msa isa MSA.AbstractMultipleSequenceAlignment
        xlabels = collectkeys(msa.matrix.dicts[1])
	    ylabels = collectkeys(msa.matrix.dicts[2])
        msamatrix = Matrix(msa) .|> string

	# For fasta files loaded with FastaIO
    elseif msa isa Vector{Tuple{String,String}}
        xlabels = [msa[i][1] for i in 1:size(msa,1)]
	    ylabels = [1:length(msa[1][2])...] |> collect .|> string
        msamatrix = [[msa[i][2]...] for i in 1:size(msa,1)] |> combinedims .|> string
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

# Examples
```julia
fig = Figure(resolution = (1100, 400))

plotmsa!( fig::Figure, msamatrix::Matrix{String}, matrixvals::Matrix{Float32};
		  xlabels = xlabels1, 	
		  ylabels = ylabels1,
		  kwargs... )
```
Keyword arguments:
xlabels ------- {1:height}
ylabels ------- {1:width}
sheetsize ----- [40,20]
gridposition -- (1,1)
colorscheme --- :viridis
markersize ---- (11.0,11.0)
markercolor --- :black
kwargs...    # forwarded to scatter plot
"""
function plotmsa!( fig::Figure, msamatrix::Observable, matrixvals::Observable;
				   xlabels = nothing, 	
				   ylabels = nothing,	# row/column indices by default
				   sheetsize = [40,20],
				   gridposition = (1,1),
				   colorscheme = :viridis,
				   markersize = (11.0,11.0),
				   markercolor = :black,
				   kwargs... )

	grid1 = fig[gridposition...] = GridLayout()
	ax = Axis(grid1[1:7,3:9];)
	
	width1 = sheetsize[1]
	height1 = sheetsize[2]
	widthrange = [1:width1...]
	heightrange = [1:height1...]

	if xlabels == nothing
		xlabels = @lift string.(1:size($matrixvals,1))
		
	end
	if ylabels == nothing
		ylabels = @lift string.(1:size($matrixvals,2))
	end

	xlabelsize =  @lift size($xlabels,1) - (height1-1)
	xlabelrange = @lift $xlabelsize:-1:1
	ylabelsize =  @lift size($ylabels,1) - (width1-1)
	ylabelrange = @lift 1:1:$ylabelsize

	sl1 = GLMakie.Slider(grid1[end+1,3:9], range = ylabelrange, startvalue = 1)
	sl1.value[] = 1
	sl2 = GLMakie.Slider(grid1[1:7,10], range = xlabelrange, startvalue = 1, horizontal = false,
		tellwidth = true, height = nothing)
	sl2.value[] = 1

	xlabelshow = lift(X->xlabels[][(X+(height1-1):-1:X)],sl2.value)	# currently shown x labels, updated with vertical right slider (sl2)
	ylabelshow = lift(X->ylabels[][(X:1:X+(width1-1))],sl1.value)	# corresponding y labels, updated with horizontal bottom slider (sl1)
	xlabelshowindex = lift(X->(X+(height1-1):-1:X), sl2.value)
	ylabelshowindex = lift(X->(X:1:X+(width1-1)), sl1.value)

	colorvals = @lift $matrixvals[$xlabelshowindex, $ylabelshowindex] |> transposed
	charmsa = @lift [x[1] for x in $msamatrix]
	charshow = @lift $charmsa[$xlabelshowindex, $ylabelshowindex]

	ax.yticks = (heightrange, xlabelshow[])
	on(xlabelshow) do ls
		ax.yticks = (heightrange, ls)
	end
	ax.xticks = ([1:width1...], ylabelshow[])
	on(ylabelshow) do ns
		ax.xticks = ([1:width1...], ns)
	end
	ax.xticklabelsize = 9
	ax.yticklabelsize = 11
	ax.xzoomlock[] = true
	ax.yzoomlock[] = true
	ax.yticklabelspace[] = 10
	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)

	heatmap!(ax, colorvals, show_grid = true, 
			colormap = colorscheme,
	)
	scatter!(ax,
			points1,
			marker = charvec,
			markersize = markersize,
			color = markercolor,
			kwargs...
	)
	hlines!(ax,
		.-(heightrange, 0.5),
		color = :black
	)
	vlines!(ax,
		.-(widthrange, 0.5),
		color = :black
	)
	ax.xgridvisible = true
	ax.xaxisposition[] = :top
	ax.xticklabelrotation[] = 1f0
	deregister_interaction!(fig.current_axis.x,:rectanglezoom)

	display(fig)
	fig
end

"""
    plotmsa( msa )

Plot a multiple sequence alignment (MSA). Returns a Figure, or
a Figure and Observables for interaction. 

# Examples
```julia
plotmsa( msamatrix::Matrix{String};
         xlabels = xlabel::Vector{String}, 	
         ylabels = ylabel::Vector{String}, 
         kwargs... )
```

Keyword arguments:
xlabels ----------- {1:height}
ylabels ----------- {1:width}
resolution -------- (1100, 400)
sheetsize --------- [40,20]
gridposition ------ (1,1)
colorscheme ------- :viridis
resdict ----------- kideradict    # Dictionary of values (::Dict{String,Float}, "Y" => 1.48) for heatmap.
kf ---------------- 2             # If resdict == kideradict, this is the Kidera Factor. KF2 is size/volume-related.
returnobservables - true          # Return Observables for interaction.
kwargs...    # forwarded to scatter plot
"""
function plotmsa(msa; resolution = (1100, 400), resdict = kideradict, kf = 2, returnobservables = true, kwargs...)
	if typeof(msa) <:Observable
		matrixvals = @lift msavalues($msa, resdict; kf = kf)
		plotmsa(msa, matrixvals; returnobservables, kwargs...)
	else
		msa = Observable(msa)
		matrixvals = @lift msavalues($msa, resdict; kf = kf)
		plotmsa(msa, matrixvals; returnobservables, kwargs...)
	end
end

"""
    plotmsa( msa, msavalues )

Plot a multiple sequence alignment (MSA). Returns a Figure, or
a Figure and Observables for interaction.

# Examples
```julia
plotmsa( msamatrix::Matrix{String}, 
		 matrixvals::Matrix{Float32};
		 xlabels = xlabel::Vector{String}, 	
		 ylabels = ylabel::Vector{String}, 
		 kwargs... )
```
Keyword arguments:
xlabels ----------- {1:height}
ylabels ----------- {1:width}
resolution -------- (1100, 400)
sheetsize --------- [40,20]
gridposition ------ (1,1)
colorscheme ------- :viridis
returnobservables - true          # Return data Observables for interaction.
kwargs...                         # forwarded to scatter plot
"""
function plotmsa(msa, matrixvals; resolution = (1100, 400), returnobservables = true, kwargs...)
	fig = Figure(resolution = resolution)

	if !(typeof(msa) <:Observable)
		msa = Observable(msa)
	end
	if !(typeof(matrixvals) <:Observable)
		matrixvals = Observable(matrixvals)
	end

	plotmsa!(fig, msa, matrixvals; kwargs...)
	
	if returnobservables == true
		return fig, msa, matrixvals
	else
		return fig
	end
end
