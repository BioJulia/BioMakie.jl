export plotstruc!,
       plotstruc             

"""
    atomradii(atoms)

Collect atom radii for plotting.
Uses BioStructures to get radii based on atomic element.

### Optional Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals
"""
function atomradii(atoms; radiustype = :covalent)
	if radiustype == :cov || radiustype == :covalent
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	elseif radiustype == :vdw || radiustype == :vanderwaals
		return [vanderwaalsradii[BioStructures.element(x)] for x in atoms]
	else
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	end
end

"""
    plotstruc!( fig, structure )

Plot a protein structure into a Figure. Position can be specified with the 
gridposition keyword argument.

# Examples
```julia
fig = Figure()
using BioStructures
struc = retrievepdb("2vb1", dir = "data/") |> Observable
sv = plotstruc!(fig, struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
sv = plotstruc!(fig, struc)
```

### Optional Arguments:
- selectors ----- [standardselector]
- resolution ---- (800,800)
- gridposition -- (1,1)
- plottype ------ :ballandstick, another option is :spacefilling
- atomcolors ---- elecolors, another option is aquacolors, or define your own dict for atoms like: "N" => :blue
"""
function plotstruc!(fig::Figure, struc::Observable;
                    selectors = [standardselector],
                    resolution = (800,800),
                    gridposition = (1,1),
                    plottype = :covalent,
                    atomcolors = elecolors,
                    markersize = 0.5,
                    algo = :knowledgebased,
                    kwargs...
                    ) 
	#
    atms = @lift defaultatom.(BioStructures.collectatoms($struc,selectors...))
    atmcords = @lift coordarray($atms) |> transpose |> collect
    colrs = @lift [atomcolors[BioStructures.element(x)] for x in $atms]

    if plottype == :spacefilling
        markersize = @lift atomradii($atms; radiustype = :vdw)
        lscene = LScene(fig[gridposition...]; show_axis = false)
        meshscatter!(lscene, atmcords; color = colrs, markersize = markersize, kwargs...)
    elseif plottype == :ballandstick
        lscene = LScene(fig[gridposition...]; show_axis = false)
        meshscatter!(lscene, atmcords; color = colrs, markersize = markersize, kwargs...)
		# :ballandstick shows the bonds (/sticks) as cylinder meshes
        bndshapes = @lift bondshapes($struc, selectors...; algo = algo)
        bndmeshes = @lift normal_mesh.($bndshapes)
        mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
    elseif plottype == :covalent
        markersize = @lift atomradii($atms; radiustype = :cov)
        lscene = LScene(fig[gridposition...]; show_axis = false)
        meshscatter!(lscene, atmcords; color = colrs, markersize = markersize, kwargs...)
    else
        println("bad plottype")
    end
end

"""
    plotstruc(structure)

Create and return a Makie Figure for a protein structure, 
along with the structure wrapped in an Observable if it wasn't Observable already. 

# Examples
```julia
using BioStructures
struc = retrievepdb("2vb1", dir = "data/") |> Observable
sv = plotstruc(struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
sv = plotstruc(struc)
```

### Optional Arguments:
- selectors ----- [standardselector]
- resolution ---- (800,800)
- gridposition -- (1,1)
- plottype ------ :ballandstick, another option is :spacefilling
- atomcolors ---- elecolors, another option is aquacolors, or define your own dict for atoms like: "N" => :blue
"""
function plotstruc(struc; returnobservables = true, kwargs...)
	fig = Figure()

    if !(typeof(struc) <:Observable)
        struc = Observable(struc)
    end

    plotstruc!(fig, struc; kwargs...)

    if returnobservables == true
		return fig, struc
	else
		return fig
	end
end
