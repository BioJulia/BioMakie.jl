using DelimitedFiles, Makie, MakieLayout
	"""
		Here is an example of a heatmap for plotting the
		change in physical property values for
		a set of double mutations.

	"""
	# load data #
	doublemutantchanges = readdlm("data\\dcchanges.csv")
	doublemutantlabels = readdlm("data\\dclabels.csv")
	doublemutantlabels = [.*(doublemutantlabels[i,1]," ", doublemutantlabels[i,2])
							for i = 1:size(doublemutantlabels,1)]

	# create layout/scene for plot #
	scene, layout = layoutscene(resolution = (800, 800));
	ax1 = layout[1:3,1:2] = LAxis(scene);
	tightlimits!(ax1)

	# add plot and other objects #
	Makie.heatmap!(ax1, doublemutantchanges; colormap = :RdBu)
	cbar1 = layout[1:3, end + 1] = LColorbar(scene, ax1.scene.plots[end], width = 30, colormap = :RdBu)    # index "end + 1" appends it past the current end
	title1 = layout[0,1:2] = LText(scene, "Physical Property Changes")    # index zero appends it before the current beginning

	# add text/labels #
	ax1.xlabel = "Property"
	ax1.ylabel = "Double Mutation"
	ax1.attributes.yticks = ManualTicks([0.5:39.5...], [doublemutantlabels...])	   # for setting custom tick labels
	ax1.attributes.xticks = ManualTicks([0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5], string.([1:10...]))
	ax1.yticklabelfont = :Consolas   # this font lines up the letters, since they are all approximately equal width

	# tweak sizes of things to my liking #
	ax1.xlabelsize = 25
	ax1.ylabelsize = 25
	title1.textsize = 40
	ax1.titlesize = 25
	ax1.titlegap = 30
	ax1.ylabelpadding = 30
	ax1.yticklabelsize = 15

	scene
