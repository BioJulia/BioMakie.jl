mutable struct MSAView
	msa
	annotations
	matrix
	figures
end
MSAView(xs::AbstractArray{Node}) = MSAView(xs..., [])
for f in (	:msa,
			:annotations,
			:matrix,
			:figures
			)
  @eval $(f)(mv::MSAView) = mv.$(f)[]
end
function msaview(   str::String;
					filetype = Stockholm,
					aligntype = "full")

	id = uppercase(str)
	pf1 = MIToS.Pfam.downloadpfam("$(id)")
	msa1 = read("$(id).stockholm.gz", Stockholm)
	annotations1 = msa1.annotations.file
	matrix1 = Matrix(msa1)
	return MSAView(  map( X->Node(X),
								[ msa1,
								  annotations1,
								  matrix1
								]))
end

function viewmsa(

pf1 = MIToS.Pfam.downloadpfam("PF00870")
msa1 = read("PF00870.stockholm.gz", Stockholm; generatemapping = true)
msa2 = read("_research\\PF00870_nr.muscle.msa", FASTA; generatemapping = true)

mat1 = msa1.matrix
mat2 = msa2.matrix

getannotsequence(msa1)
getannotsequence(msa2)

width1 = 40
height1 = 20
resolution1 = (1500, 600)
fig = Figure(resolution = resolution1)
fig |> display

# set the scene
fig, scene, layout = figures(resolution = resolution)
ax1 = layout[1:7,3:9] = LAxis(scene)
tightlimits!(ax1)
labels = msa1.matrix.dicts[1] |> keys |> collect |> Node
nums = msa1.matrix.dicts[2] |> keys |> collect |> Node
labelssize = @lift size($labels,1) - (height1-1)
labelsrange = @lift $labelssize:-1:1
numssize = @lift size($nums,1) - (width1-1)
numsrange = @lift 1:1:$numssize

# sliders
sl1 = layout[end+1,3:9] = LSlider(scene, range = numsrange, startvalue = 1)
sl1.value = 1
sl2 = layout[1:7,10] = LSlider(scene, range = labelsrange, startvalue = 1, horizontal = false,
	tellwidth = true, height = nothing)
sl2.value = labelssize[]

# menu 1
menutext1 = layout[1,1:2] = LText(scene, "colors:")
clrdict = Dict("viridis" => :viridis,
			   "redblue" => :RdBu)
menu1 = layout[2,1:2] = LMenu(scene, options = ["viridis", "redblue"], startvalue = "viridis")
menu1.selection = "viridis"

# menu 2
menutext2 = layout[3,1:2] = LText(scene, "colorscheme:")
clrscheme = Dict("size" => 2,
				 "hydrophobicity" => 4)
menu2 = layout[4,1:2] = LMenu(scene, options = ["size", "hydrophobicity"], startvalue = "size")
menu2.selection = "size"

# main title
title1 = layout[0,2:3] = LText(scene, "$(uppercase(str)): $(ms.msa[].annotations.file["DE"])")

# making data Nodes
strmsa = Matrix(msa(ms)) .|> string
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
xaxis_top!(ax1)
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

GLMakie.display(scene)

return fig
end
