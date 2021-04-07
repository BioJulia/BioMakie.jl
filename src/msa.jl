"""
    viewmsa(args)

Create and return a Makie Figure for a Pfam MSA.
# Examples
```julia
vm = viewmsa("PF00062")
```
"""
function viewmsa(   msa::MSA.AbstractMultipleSequenceAlignment;
					sheetsize = [40,20],
					resolution = (1500, 600),
                    colorscheme = :viridis,
                    colorval = 2
				)

	width1 = sheetsize[1]
	height1 = sheetsize[2]

	fig = Figure(resolution = resolution)
	ax1 = Axis(fig[1:7,3:9])
	tightlimits!(ax1)
	labels = msa.matrix.dicts[1] |> keys |> collect |> GLMakie.Node
	nums = msa.matrix.dicts[2] |> keys |> collect |> GLMakie.Node
	labelssize = @lift size($labels,1) - (height1-1)
	labelsrange = @lift $labelssize:-1:1
	numssize = @lift size($nums,1) - (width1-1)
	numsrange = @lift 1:1:$numssize

	sl1 = Slider(fig[end+1,3:9], range = numsrange, startvalue = 1)
	sl1.value = 1
	sl2 = Slider(fig[1:7,10], range = labelsrange, startvalue = 1, horizontal = false,
		tellwidth = true, height = nothing)
	sl2.value = labelssize[]

	# menutext1 = Label(fig[1,1:2], "colors:")
	# clrdict = Dict("viridis" => :viridis,
	# 			   "redblue" => :RdBu)
	# menu1 = Menu(fig[2,1:2], options = ["viridis", "redblue"], startvalue = "viridis")
	# menu1.selection = "viridis"
    #
	# menutext2 = Label(fig[3,1:2], "colorscheme:")
	# clrscheme = Dict("size" => 2,
	# 				 "hydrophobicity" => 4)
	# menu2 = Menu(fig[4,1:2], options = ["size", "hydrophobicity"], startvalue = "size")
	# menu2.selection = "size"
	# title1 = Label(fig[0,2:3], "$(uppercase(msa.annotations.file["AC"])): $(msa.annotations.file["DE"])")

    colorval = GLMakie.Node(colorval)
	strmsa = Matrix(msa) .|> string
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
			strokecolor = :black
	        )
	heatmap!(ax1, msashow, show_grid = true, show_axis = true,
	       colormap = colorscheme#,
	       # ax1.aspect = AxisAspect(axisaspect)
           )
	return fig
end
function viewmsa(str::String; kwargs...)
	MIToS.Pfam.downloadpfam(str)
	msa1 = read("$(str).stockholm.gz", MIToS.MSA.Stockholm; generatemapping = true)
	return viewmsa(msa1; kwargs...)
end
f1 = FastaIO.readfasta("C:\\Users\\kool7\\Google Drive\\BioMakie.jl\\data\\Flavivirus_data\\newData\\KMAT\\NS3_KMAT.fas")
# f2 = [f1[i][2] for i in 1:size(f1,1)]
# [[f2[i]...] for i in 1:size(f2,1)] |> combinedims .|> string
# length(f1[1][2])
# function viewmsa(   msa::Vector{Tuple{String,String}};
# 					sheetsize = [40,18],
# 					resolution = (1500, 600),
#                     colorscheme = :viridis,
#                     colorval = 2
# 				)
#
#     width1 = sheetsize[1]
#     height1 = sheetsize[2]
#
#     positions = [1:length(msa[1][2])...]
#     f2 = [f1[i][2] for i in 1:size(f1,1)]
#     mat = [[f2[i]...] for i in 1:size(f2,1)] |> combinedims .|> string
#
# 	fig = Figure(resolution = resolution)
# 	ax1 = Axis(fig[1:7,3:9])
# 	tightlimits!(ax1)
# 	labels = GLMakie.Node([msa[i][1] for i in 1:size(msa,1)])
# 	nums = GLMakie.Node(positions)
#     labelssize = @lift size($labels,1) - (height1-1)
# 	labelsrange = @lift $labelssize:-1:1
# 	numssize = @lift size($nums,1) - (width1-1)
# 	numsrange = @lift 1:1:$numssize
#
# 	sl1 = Slider(fig[end+1,3:9], range = numsrange, startvalue = 1)
# 	sl1.value = 1
# 	sl2 = Slider(fig[1:7,10], range = labelsrange, startvalue = 1, horizontal = false,
# 		tellwidth = true, height = nothing)
# 	sl2.value = labelssize[]
#
# 	# menutext1 = Label(fig[1,1:2], "colors:")
# 	# clrdict = Dict("viridis" => :viridis,
# 	# 			   "redblue" => :RdBu)
# 	# menu1 = Menu(fig[2,1:2], options = ["viridis", "redblue"], startvalue = "viridis")
# 	# menu1.selection = "viridis"
#     #
# 	# menutext2 = Label(fig[3,1:2], "colorscheme:")
# 	# clrscheme = Dict("size" => 2,
# 	# 				 "hydrophobicity" => 4)
# 	# menu2 = Menu(fig[4,1:2], options = ["size", "hydrophobicity"], startvalue = "size")
# 	# menu2.selection = "size"
# 	# title1 = Label(fig[0,2:3], "$(uppercase(msa.annotations.file["AC"])): $(msa.annotations.file["DE"])")
#
#     colorval = GLMakie.Node(colorval)
#
# 	strmsa = mat
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
#
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
# 	# charcolors = lift(msashow) do mss
# 	# 	arr = Symbol[]
# 	# 	for X in mss
# 	# 		X < 0.0 ? push!(arr,:white) : push!(arr,:black)
# 	# 	end
# 	# 	arr
# 	# end
# 	scatter!(ax1,
# 	        points1,
# 	        marker = charvec,
# 	        markersize = (10.0,11.0),
# 			color = :black,
# 			strokecolor = :black
# 	        )
# 	heatmap!(ax1, msashow, show_grid = true, show_axis = true,
# 	       colormap = colorscheme#,
# 	       # ax1.aspect = AxisAspect(axisaspect)
#            )
# 	return fig
# end
function viewmsa(   msa::Vector{Tuple{String,String}};
					sheetsize = [18,18],
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
    width1 = sheetsize[2]
    height1 = sheetsize[1]
    fig = Figure(resolution = resolution)
    ax1 = Axis(fig[1:7,3:9])
    tightlimits!(ax1)
    labels = GLMakie.Node([msa[i][1] for i in 1:size(msa,1)])
    nums = GLMakie.Node(positions)
    labelssize = @lift size($labels,1) - (height1-1)
    labelsrange = @lift $labelssize:-1:1
    numssize = @lift size($nums,1) - (width1-1)
    numsrange = @lift 1:1:$numssize

    sl1 = Slider(fig[end+1,3:9], range = numsrange, startvalue = 1)
    sl1.value = 1
    sl2 = Slider(fig[1:7,10], range = labelsrange, startvalue = 1, horizontal = false,
    	tellwidth = true, height = nothing)
    sl2.value = 1#labelssize[]
    # menutext1 = Label(fig[1,1:2], "colors:")
    # clrdict = Dict("viridis" => :viridis,
    # 			   "redblue" => :RdBu)
    # menu1 = Menu(fig[2,1:2], options = ["viridis", "redblue"], startvalue = "viridis")
    # menu1.selection = "viridis"
    #
    # menutext2 = Label(fig[3,1:2], "colorscheme:")
    # clrscheme = Dict("size" => 2,
    # 				 "hydrophobicity" => 4)
    # menu2 = Menu(fig[4,1:2], options = ["size", "hydrophobicity"], startvalue = "size")
    # menu2.selection = "size"
    # title1 = Label(fig[0,2:3], "$(uppercase(msa.annotations.file["AC"])): $(msa.annotations.file["DE"])")

    colorval = GLMakie.Node(colorval)
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
    		strokecolor = :black
            )
    heatmap!(ax1, msashow, show_grid = true, show_axis = true,
           colormap = colorscheme
           )
    ax1.attributes.xaxisposition[] = :top
    deregister_interaction!(fig.current_axis.x,:rectanglezoom)
    return fig
end
fm1 = viewmsa(f1)
# using Observables
# events(fm1.scene)
# pc = fm1.scene.camera_controls.x
# using AbstractPlotting
# ax1 = fm1.current_axis
# AbstractPlotting.setup_camera!(fm1.scene,)
# zoom!(fm1.scene,)
# GLMakie.remove_automatic!(events(fm1.scene))
# onmouseleftup()
off(fm1.scene.events.mousedrag.listeners[1].mouseevent,
    fm1.scene.events.mousedrag.listeners[1].mouseevent.listeners[1])
sr = select_rectangle(fm1.scene)
on(sr) do sr
    print("$(sr)")
end
fm1.layout.content[1].content
fm1.scene.events
@async for i in 1:3
    fm1.scene.events.hasfocus |> print
    sleep(1)
end
p1 = on(fm1.scene.events.mousedrag.listeners[1].mouseevent) do foc
    print("$(fm1.scene.events.mousedrag.listeners[1].mouseevent.listeners[1])")
end
fm1.scene.events.mousedrag.listeners[1].mouseevent.listeners[1]
fm1.layout.content[1]
fm1.current_axis.x.interactions
.yzoomlock
onmouseleftup(fm1.scene,)
fm1.current_axis.x.interactions[:rectanglezoom]
fm1.scene.camera#yzoomlock[]
xzoomlock
Limit(fm1.scene)
selection_rect!(fm1.scene,)
function selection_rect!(scene, cam, key)
    rect = RefValue(FRect(NaN, NaN, NaN, NaN))
    lw = 2f0
    scene_unscaled = Scene(
        scene, transformation = Transformation(),
        cam = copy(camera(scene)), clear = false, raw = true
    )
    scene_unscaled.clear = false
    scene_unscaled.updated = Node(false)
    rect_vis = lines!(
        scene_unscaled,
        rect[],
        linestyle = :dot,
        linewidth = 2f0,
        color = (:black, 0.4),
        visible = false,
        raw = true
    )
    waspressed = RefValue(false)
    dragged_rect = on(camera(scene), events(scene).mousedrag, key) do drag, key
        if ispressed(scene, key) && is_mouseinside(scene)
            mp = events(scene).mouseposition[]
            mp = camspace(scene, cam, mp)
            if drag == Mouse.down
                waspressed[] = true
                rect_vis[:visible] = true # start displaying
                rect[] = FRect(mp, 0, 0)
                rect_vis[1] = rect[]
            elseif drag == Mouse.pressed
                mini = minimum(rect[])
                rect[] = FRect(mini, mp - mini)
                # mini, maxi = min(mini, mp), max(mini, mp)
                rect_vis[1] = rect[]
            end
        else
            if drag == Mouse.up && waspressed[]
                waspressed[] = false
                # r = absrect(rect[])
                # w, h = widths(r)
                # if w > 0.0 && h > 0.0
                #     update_cam!(scene, cam, r)
                # end
                rect[] = FRect(NaN, NaN, NaN, NaN)
                rect_vis[1] = rect[]
            end
            # always hide if not the right key is pressed
            rect_vis[:visible] = false # hide
        end
        return rect[]
    end
    rect_vis, dragged_rect
end
AbstractPlotting.reset!(fm1.scene.camera,)
on(fm1.scene.events.mousebuttons) do mb
end
fm1.current_axis.x.limits.listeners[3].f.observable.listeners[1]
Observables.off
GLMakie.onpick(fm1.scene,)
fm1.scene.clear = true
fm1.scene.camera
deregister_interaction!(
off(fm1.current_axis.x.limits.listeners[3].f.observable.listeners[1])
interactions(fm1.current_axis.x)
tightlimits!(Axis(fm1.scene))
false, HyperRectangle{2,Float32}(Float32[0.0, 0.0], Float32[1.0, 1.0]), AbstractPlot[])
deregister_interaction!(fm1.current_axis.x,:rectanglezoom)
disconnect!()
disconnect!(fm1.scene.current_screens[1],:rectanglezoom)
fm1.scene.camera.view.listeners

Axis(fm1.scene)
