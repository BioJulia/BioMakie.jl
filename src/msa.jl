using MIToS, MIToS.MSA

mutable struct MSAView
	msa::Node#{AbstractMultipleSequenceAlignment}
	matrix::Node#{AbstractArray{MIToS.MSA.Residue,2}}
	sequences::Node#{Dict{Tuple{String,String},String}}
	residues::Node#{Dict{Tuple{String,String},String}}
	annotations::Node#{Tuple{OrderedDict{String,Int64}}}
	scenes
	layout
end
MSAView(xs::AbstractArray{Node}) = MSAView(xs..., [], [])

for f in (	:msa,
			:matrix,
			:sequences,
			:residues,
			:annotations,
			)
  @eval $(f)(mv::MSAView) = mv.$(f)[]
end

function msaview(str::String; dir = "../data/MSA", filetype = Stockholm)
	id = uppercase(str)
	msa1 = read("http://pfam.xfam.org/family/$(id)/alignment/full", filetype)
	matrix1 = msa1.matrix
	sequences1 = msa1.annotations.sequences
	residues1 = msa1.annotations.residues
	annotations1 = msa1.matrix.dicts
	return MSAView(  map( X->Node(X),
								[ msa1,
								  matrix1,
							  	  sequences1,
							  	  residues1,
								  annotations1,
								]
							  )
						)
end

function viewmsa(str::String)
	mv = msaview(str)
	scene, layout = layoutscene(8,16; resolution = (600,900))
	ms_scene = layout[1:3,1:2] = LAxis(scene)
	tightlimits!(ms_scene)
	x_width = size(msa,1)
	y_height = size(msa,2)
	Makie.heatmap!(ms_scene, doublemutantchanges; colormap = :RdBu)
	ms_scene.attributes.yticks = ([0.5:(parse(Float64,"$(y_height).5"))...], [doublemutantlabels...])	   # for setting custom tick labels
	ms_scene.attributes.xticks = ([0.5:(parse(Float64,"$(x_width).5"))...])

	display(scene)

	sv.scenes = [scene, ms_scene]
	sv.layout = layout
	return mv
end
