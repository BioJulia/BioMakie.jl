function viewstrucs!(scenein::AbstractScene,
					strs::AbstractArray{String};
					dir = "",
					showbonds = true,
					colors = "element",
					resolution = (1200,900))

	len = length(strs)
	len > 0 || throw("length of input for `viewstrucs` must be > 0")
	len2 = length(colors)
    scene, layout = layoutscene(1, 1; resolution = resolution)

    svs = [structureview(string(str); dir = dir) for str in strs]
    sc_scenes = [LScene(scenein) for s in strs]
    pdbtexts = [LText(scenein, text = uppercase(str); textsize = 35-len) for str in strs]
	typeof(colors)<:AbstractArray ? colors = Node(colors) : colors = Node([colors])

    for i in 1:len
        sc = sc_scenes[i]
        pt = pdbtexts[i]
        layout[2:8,(end+1):(end+8)] = sc
        layout[1,(end-4):(end-3)] = pt
		(len > 1 && len == len2) ? colors2 = colors[][i] : colors2 = colors[][1]
        meshscatter!(sc, lift(atomcoords,svs[i].atoms);
            color = lift(X->atomcolors(X; color = colors2),svs[i].atoms),
            markersize = lift(X->(1/3).*atomradii(X),svs[i].atoms), show_axis = false)
        if showbonds == true
    		bonds1 = normal_mesh.(bondshapes(bonds(residues(svs[i]))))
    		mesh!(sc, bonds1[1], color = RGBAf0(0.5,0.5,0.5,0.0))
    		for i = 1:size(bonds1,1); mesh!(sc, bonds1[i], color = RGBAf0(0.5,0.5,0.5,0.8), backgroundcolor = RGBAf0(0.5,0.5,0.5,0.8)); end
    	end
        svs[i].scenes = [scenein,sc]
        svs[i].layout = layout
    end
    AbstractPlotting.display(scenein)
    deletecol!(layout, 1)
    if len == 1
        return svs[1]
    end
	return svs
end