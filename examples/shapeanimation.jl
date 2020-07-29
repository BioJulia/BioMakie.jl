function frames(id::String, frames::T2, modes::T3, phases::T4, extrp::String = "harmonic") where {T2,T3,T4}
    step = 1
    frames = try
        splatrange(frames)
    catch
        frames
    end
    filenames = []
    phases = "$(phases)"
    if T3 <: AbstractArray{UnitRange{Int64},1}
        modes = splatrange(modes[1])
        step = 1
        if extrp == "linear"
            filenames = map(x -> "$(id)_$(modes[1])_$(step)_$(modes[end])_$(phases)_lin_frame_$(x)", frames)
        else
            filenames = map(x -> "$(id)_$(modes[1])_$(step)_$(modes[end])_$(phases)_frame_$(x)", frames)
        end
    elseif T3 <: AbstractArray{StepRange{Int64,Int64},1} || modes ∈ ["1:3","1:5"]
        # step = Base.step(modes[1])
        # modes = splatrange(modes[1])
        if extrp == "linear"
			if modes == "1:3"
				filenames = map(x -> "$(id)_1_1_3_$(phases)_lin_frame_$(x)", frames)
			else
				filenames = map(x -> "$(id)_1_1_5_$(phases)_lin_frame_$(x)", frames)
			end
        else
			if modes == "1:3"
				filenames = map(x -> "$(id)_1_1_3_$(phases)_frame_$(x)", frames)
			else
				filenames = map(x -> "$(id)_1_1_5_$(phases)_frame_$(x)", frames)
			end
        end
    elseif T3 <: AbstractArray{Int64,1} || modes ∈ ["1","2","3"]
        # modes = "$([modes...])"
        if extrp == "linear"
			if modes == "1"
				filenames = map(x -> "$(id)_1_$(phases)_lin_frame_$(x)", frames)
			elseif modes == "2"
				filenames = map(x -> "$(id)_2_$(phases)_lin_frame_$(x)", frames)
			elseif modes == "3"
				filenames = map(x -> "$(id)_3_$(phases)_lin_frame_$(x)", frames)
			else
				filenames = map(x -> "$(id)_1_$(phases)_lin_frame_$(x)", frames)
			end
            # filenames = map(x -> "$(id)_$(modes)_$(phases)_lin_frame_$(x)", frames)
        else
			if modes == "1"
				filenames = map(x -> "$(id)_1_$(phases)_frame_$(x)", frames)
			elseif modes == "2"
				filenames = map(x -> "$(id)_2_$(phases)_frame_$(x)", frames)
			elseif modes == "3"
				filenames = map(x -> "$(id)_3_$(phases)_frame_$(x)", frames)
			else
				filenames = map(x -> "$(id)_1_$(phases)_frame_$(x)", frames)
			end
            # filenames = map(x -> "$(id)_$(modes)_$(phases)_frame_$(x)", frames)
        end
    else
        if extrp == "linear"
            filenames = map(x -> "$(id)_$(modes)_$(phases)_lin_frame_$(x)", frames)
        else
            filenames = map(x -> "$(id)_$(modes)_$(phases)_frame_$(x)", frames)
        end
    end
    return reshape(filenames, (length(frames)))
end
using Dates

function animatetask!(proteinview, startt = 1, endd = 10; times = 2, sleeps = 10^8, prots = prots[])
    sleep(0.5)
    for j = 1:times
        for i = range(startt, endd; step = 1)
            proteinview.atoms[] = collectatoms(prots[i])
            sleep(Nanosecond(sleeps))
        end
		proteinview.atoms[] = collectatoms(prots[1])
		proteinview.atoms[] = collectatoms(read("examples/data/2VB1modes/2VB1_1_1_5_11111_lin_frame_1.pdb",
		    BioStructures.PDB; structure_name="2VB1_1_1_5_11111_lin_frame_1.pdb"))
    end
end

function viewanimation()
	sv = structureview("2VB1")
	scene, layout = layoutscene(10, 10; resolution = (1100,900))
	sc_scene = layout[2:9,1:6] = LScene(scene)
	extrap1 = layout[7,8:10] = LMenu(scene, options = ["linear","harmonic"])
	extraptxt1 = layout[7,7] = LText(scene, text = "extrapolation:")
	frames1 = frames("2VB1",1:5:100,[1:5],"11111","linear") |> Node
	frame1pdb = ["$(x).pdb" for x in frames1[]]
	prots = [read("examples/data/2VB1modes/$(frame1pdb[intt])",
	    BioStructures.PDB; structure_name="$(frames1[][intt]).pdb") for intt in 1:size(frames1[],1)] |> Node
	alpha1 = layout[3,8:10] = LSlider(scene, range = 1.5:0.01:9.0, startvalue = 2.5)
	alphatxt1 = Makie.lift(alpha1.value) do s1; string("alpha = ", round(s1, sigdigits = 2)); end
	pdbtext = layout[1,1:6] = LText(scene, text = "2VB1"; textsize = 35)
	alphatext = layout[2,8:10] = LText(scene, text = alphatxt1)
    modes1 = layout[5,8:10] = LMenu(scene, options = ["1","2","3","1:3","1:5"])
    modestext1 = layout[5,7] = LText(scene, text = "modes:")
	phasechoices = Dict("1:5" => ["11111","01111","10111","11011","11101","11110"],
						"1:3" => ["111","010","011","101"],
						"3" => ["1"],
						"2" => ["1"],
						"1" => ["1"])
    phases1 = layout[6,8:10] = LMenu(scene, options = ["11111"])
	modes2 = "1:5"
	extrap2 = "linear"
	phasechoices2 = "11111"
	on(modes1.selection) do s
		modes2 = s
    	phases1 = layout[6,8:10] = LMenu(scene, options = phasechoices["$s"])
		on(phases1.selection) do p
			phasechoices2 = p
		end
		phasechoices2 = phases1.options[][1]
	end
	on(extrap1.selection) do e
		extrap2 = e
	end
	on(phases1.selection) do p
		phasechoices2 = p
	end
    phasestext1 = layout[6,7] = LText(scene, text = "phases:")
    button1 = layout[8,9:10] = LButton(scene, label = "animate")
	button2 = layout[8,7:8] = LButton(scene, label = "load frames")
	framestext1 = layout[9,8:9] = LText(scene, text =
						lift(X->"frames loaded: $(modes2) $(phasechoices2) $(extrap2)",button2.clicks),
						textsize = 15,
						tellheight = false)
    lift(button1.clicks) do c
		if c > 0
			@async animatetask!(sv,1,20;times = 2, sleeps = 2*10^7,prots = prots[])
		end
	end
	lift(button2.clicks) do c
		modes3 = try
			steprange(modes2)
		catch
			modes2
		end
		frames1 = frames("2VB1",1:5:100,modes3,phasechoices2,extrap2)
		frame1pdb = ["examples/data/2VB1modes/$(x)" for x in frames1]
		prots[] = [read("$(frame1pdb[intt]).pdb",
			BioStructures.PDB; structure_name="$(frames1[intt])") for intt in 1:size(frames1,1)]
	end
	atms = atomcoords(sv.atoms[])
	sliderval = alpha1.value
	protatms = sv.atoms
	proteinshape = @lift let a = $protatms; getalphashape(atomcoords(a),$sliderval); end
	alphaconnect = Makie.lift(proteinshape) do a1; a1[3]; end
	alphaedges = @lift atomcoords(sv)[$(proteinshape)[2],:] |> linesegs
	alphaverts = @lift atomcoords(sv)[$(proteinshape)[1],:]
	surfarea = @lift surfacearea(atomcoords(sv), $(proteinshape)[3])
	surfatext = layout[4,8:10] = LText(scene, text = lift(X->string("surface area = ",
                                    round(Int64, X), "  Å"), surfarea), textsize = 15)
	# mesh!(sc_scene, alphaverts, alphaconnect)
	scatter!(sc_scene, alphaverts, markersize = 0.5, color = :blue, show_axis = false)
	linesegments!(sc_scene, alphaedges, color = :green, show_axis = false)

	display(scene)
	sc_scene.scene.center = false

	sv.scenes = [scene,sc_scene]
	sv.layout = layout
	return sv
end
