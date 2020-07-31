mutable struct MSAView
	msa::Node{AbstractMultipleSequenceAlignment}
	annotations::Node{OrderedDict{String,String}}
	matrix::Node{AbstractArray{MIToS.MSA.Residue,2}}
	scenes
	layout
end
MSAView(xs::AbstractArray{Node}) = MSAView(xs..., [], [])

for f in (	:msa,
			:annotations,
			:matrix,
			)
  @eval $(f)(mv::MSAView) = mv.$(f)[]
end

function msaview(str::String; dir = "../data/MSA", filetype = MSA.Stockholm)
	id = uppercase(str)
	msa1 = read("http://pfam.xfam.org/family/$(id)/alignment/full", filetype)
	annotations1 = msa1.annotations.file
	matrix1 = Matrix(msa1)
	return MSAView(  map( X->Node(X),
								[ msa1,
								  annotations1,
								  matrix1
								]
							  )
						)
end

function viewmsa(str::String)
	ms = msaview(str)
	scene, layout = layoutscene(resolution = (1800, 600))
	strmsa = Matrix(msa(ms)) .|> string
	strmsavals = @. kdict(strmsa)
	strmsavals2 = strmsavals |> combinedims
	clrdict = Dict("viridis" => :viridis,
				   "redblue" => :RdBu)
	clrscheme = Dict("size" => 2,
					 "hydrophobicity" => 4)
	menu2 = layout[4,9:10] = LMenu(scene, options = ["size", "hydrophobicity"], startvalue = "size")
	menu2.selection = "size"
	fixtmsa = lift(X->replace(strmsavals2[clrscheme[X],:,:], nothing => 0.0),menu2.selection)
	labels = ms.msa[].matrix.dicts[1] |> keys |> collect |> Node
	nums = ms.msa[].matrix.dicts[2] |> keys |> collect |> Node
	labelssize = @lift size($labels,1) - 19
	labelsrange = @lift $labelssize:-1:1
	numssize = @lift size($nums,1) - 39
	numsrange = @lift 1:1:$numssize
	ax1 = layout[1:5,1:7] = LAxis(scene, xgridcolor = :black, ygridcolor = :black)
	tightlimits!(ax1)
	sl1 = layout[end+1,1:7] = LSlider(scene, range = numsrange, startvalue = 1)
	sl1.value = 1
	sl2 = layout[1:5,8] = LSlider(scene, range = labelsrange, startvalue = 1, horizontal = false,
	    tellwidth = true, height = nothing, width = Auto())
	sl2.value = labelssize[]
	menu1 = layout[2,9:10] = LMenu(scene, options = ["viridis", "redblue"], startvalue = "viridis")
	menu1.selection = "viridis"
	menutext1 = layout[1,9:10] = LText(scene, "colors:")
	menutext2 = layout[3,9:10] = LText(scene, "colorscheme:")
	title1 = layout[0,1:2] = LText(scene, uppercase("$(str): $(ms.msa[].annotations.file["DE"])"))
	labelshow = lift(X->labels[][(X+19:-1:X)],sl2.value)
	numsshow = lift(X->nums[][(X:1:X+39)],sl1.value)
	labelshow2 = lift(X->(X:1:X+19),sl2.value)
	numsshow2 = lift(X->(X:1:X+39),sl1.value)
	msashow = @lift $fixtmsa[$labelshow2,$numsshow2] |> _t

	heatmap!(ax1, msashow; show_grid = true, show_axis = true,
	                colormap = lift(X->clrdict[X],menu1.selection))

	ax1.yticks = ([0.5:(parse(Float64,"$(19).5"))...], labelshow[])
	on(labelshow) do ls
	    ax1.yticks = ([0.5:(parse(Float64,"$(19).5"))...], ls)
	end
	ax1.xticks = ([0.5:(parse(Float64,"$(39).5"))...], numsshow[])
	on(numsshow) do ns
	    ax1.xticks = ([0.5:(parse(Float64,"$(39).5"))...], ns)
	end
	ax1.xticklabelsize = 10
	ax1.yticklabelsize = 15

	display(scene)

	ms.scenes = [scene,ax1]
	ms.layout = layout
	return ms
end
