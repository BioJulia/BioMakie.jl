"""
    viewmsa(args)

Create and return a Makie Figure for a Pfam MSA
# Examples
```julia
vm = viewmsa("PF00062")
```
"""
function viewmsa(   msa::AbstractMultipleSequenceAlignment;
					sheetsize = [40,20],
					resolution = (1500, 600)
				)

	width1 = sheetsize[1]
	height1 = sheetsize[2]

	# if AbstractPlotting.current_backend[] == GLMakie.GLBackend()
	# 	Slider = GLMakie.Slider
	# elseif AbstractPlotting.current_backend[] == WGLMakie.WGLBackend()
	# 	Slider = JSServe.Slider
	# else
	# 	error("problem with AbstractPlotting backend")
	# end

	# set the scene
	fig = Figure(resolution = resolution)
	ax1 = Axis(fig[1:7,3:9])
	tightlimits!(ax1)
	labels = msa.matrix.dicts[1] |> keys |> collect |> Node
	nums = msa.matrix.dicts[2] |> keys |> collect |> Node
	labelssize = @lift size($labels,1) - (height1-1)
	labelsrange = @lift $labelssize:-1:1
	numssize = @lift size($nums,1) - (width1-1)
	numsrange = @lift 1:1:$numssize

	# sliders
	sl1 = Slider(fig[end+1,3:9], range = numsrange, startvalue = 1)
	sl1.value = 1
	sl2 = Slider(fig[1:7,10], range = labelsrange, startvalue = 1, horizontal = false,
		tellwidth = true, height = nothing)
	sl2.value = labelssize[]

	# menu 1
	menutext1 = Label(fig[1,1:2], "colors:")
	clrdict = Dict("viridis" => :viridis,
				   "redblue" => :RdBu)
	menu1 = Menu(fig[2,1:2], options = ["viridis", "redblue"], startvalue = "viridis")
	menu1.selection = "viridis"

	# menu 2
	menutext2 = Label(fig[3,1:2], "colorscheme:")
	clrscheme = Dict("size" => 2,
					 "hydrophobicity" => 4)
	menu2 = Menu(fig[4,1:2], options = ["size", "hydrophobicity"], startvalue = "size")
	menu2.selection = "size"

	# main title
	title1 = Label(fig[0,2:3], "$(uppercase(msa.annotations.file["AC"])): $(msa.annotations.file["DE"])")

	# making data Nodes
	strmsa = Matrix(msa) .|> string
	strmsavals = [ kdict(i) for i in strmsa ]  # get Kidera factor values
	strmsavals2 = strmsavals |> combinedims
	labelshow = lift(X->labels[][(X+(height1-1):-1:X)],sl2.value)
	numsshow = lift(X->nums[][(X:1:X+(width1-1))],sl1.value)
	labelshow2 = lift(X->(X+(height1-1):-1:X),sl2.value)
	numsshow2 = lift(X->(X:1:X+(width1-1)),sl1.value)
	fixtmsa = lift(X->replace(strmsavals2[clrscheme[X],:,:], nothing => 0.0),menu2.selection)
	msashow = @lift $fixtmsa[$labelshow2,$numsshow2] |> _t
	charmsa = [x[1] for x in strmsa]
	charshow = @lift charmsa[$labelshow2,$numsshow2]

	# setting tick labels
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

	# adjustments
	ax1.xticklabelsize = 9
	ax1.yticklabelsize = 13
	ax1.xzoomlock[] = true
	ax1.yzoomlock[] = true
	# xaxis_top!(ax1)
	axisaspect = 2.3
	ax1.yticklabelspace[] = 200

	# plotting
	poly!(ax1, [FRect2D(x, y, 1, 1) for x in 0:(width1-1) for y in 0:(height1-1)],
		 	color = :transparent, strokecolor = :black, strokewidth = 1)

	points1 = [Point2f0(x,y) for x in widthrange for y in heightrange] |> collect
	charvec = @lift SplitApplyCombine.flatten($charshow)
	# charcolors = lift(msashow) do mss
	# 	arr = Symbol[]
	# 	for X in mss
	# 		X < 0.0 ? push!(arr,:white) : push!(arr,:black)
	# 	end
	# 	arr
	# end

	scatter!(ax1,
	        points1,
	        marker = charvec,
	        markersize = (10.0,11.0),
			color = :black,
			strokecolor = :transparent
	        )

	heatmap!(ax1, msashow, show_grid = true, show_axis = true,
	    colormap = lift(X->clrdict[X],menu1.selection))

	ax1.aspect = AxisAspect(axisaspect)

	return fig
end
function viewmsa(str::String; kwargs...)
	MIToS.Pfam.downloadpfam(str)
	msa1 = read("$(str).stockholm.gz", Stockholm; generatemapping = true)
	return viewmsa(msa1; kwargs...)
end
