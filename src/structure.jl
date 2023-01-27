export atomradii,
       plotstruc!,
       plotstruc             

"""
    atomradii(atoms)

Collect atom radii based on element for plotting.

### Optional Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals
"""
function atomradii(atoms::Vector{T}; radiustype = :covalent) where T<:BioStructures.AbstractAtom
	if radiustype == :cov || radiustype == :covalent
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	elseif radiustype == :vdw || radiustype == :vanderwaals
		return [vanderwaalsradii[BioStructures.element(x)] for x in atoms]
	else
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	end
end
function atomradii(atoms::Vector{T}; radiustype = :covalent) where T<:MIToS.PDB.PDBAtom
	if radiustype == :cov || radiustype == :covalent
		return [covalentradii[x.element] for x in atoms]
	elseif radiustype == :vdw || radiustype == :vanderwaals
		return [vanderwaalsradii[x.element] for x in atoms]
	else
		return [covalentradii[x.element] for x in atoms]
	end
end

"""
    plotstruc!( fig, structure )

Plot a protein structure(/chain/residues/atoms) into a Figure. 

# Examples
```julia
fig = Figure()

using MIToS.PDB
pdbfile = MIToS.PDB.downloadpdb("2HHB")
struc = MIToS.PDB.read(pdbfile, PDBML) |> Observable
strucplot = plotstruc!(fig, struc)

chain_A = pdb = @residues struc model "1" chain "A" group "ATOM" residue All
strucplot = plotstruc!(fig, chain_A)

chnatms = @atoms res_2hhb model "1" chain "A" group "ATOM" residue All atom All
strucplot = plotstruc!(fig, chnatms)

using BioStructures
struc = retrievepdb("2vb1", dir = "data/") |> Observable
strucplot = plotstruc!(fig, struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
strucplot = plotstruc!(fig, struc)

chain_A = retrievepdb("2hhb", dir = "data/")["A"] |> Observable
strucplot = plotstruc!(fig, chain_A)
```

### Optional Arguments:
- selectors ----- [standardselector]
- resolution ---- (800,600)
- gridposition -- (1,1)
- plottype ------ :covalent, :ballandstick, or :spacefilling
- atomcolors ---- elecolors, other options, or define your own dict for atoms like: "N" => :blue
- markersize ---- 0.0
- markerscale --- 1.0
- bonds --------- :knowledgebased, :covalent, or :distance
- distance ------ 1.9  # distance cutoff for bonds
- kwargs... ----- keyword arguments passed to atom `meshscatter`

"""
function plotstruc!(fig::Figure, struc::Observable;
                    selectors = [standardselector],
                    resolution = (800,600),
                    gridposition = (1,1),
                    plottype = :covalent,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bonds = :knowledgebased,
                    distance = 1.9,
                    kwargs...
                    ) 
	#
    if struc[] isa BioStructures.StructuralElementOrList
        atms = @lift defaultatom.(BioStructures.collectatoms($struc,selectors...))
        atmcords = @lift coordarray($atms) |> transpose |> collect
        colrs = @lift [atomcolors[BioStructures.element(x)] for x in $atms]
        inspectorlabel = (self, i, p) -> "$(atms[][i].residue)\n$(atms[][i])"
    elseif struc[] isa Vector{MIToS.PDB.PDBResidue}
        atms = @lift [$struc[i].atoms for i in 1:length($struc)] |> flatten
        atmcords = @lift atmcords = [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
        colrs = @lift [atomcolors[x.element] for x in $atms]
        inspectorlabel = (self, i, p) -> "atom: $(atm1.atom)   element: $(atm1.element)   coordinates: $(atm1.coordinates)\noccupancy: $(atm1.occupancy)   B: $(atm1.B)"
    elseif struc[] isa Vector{MIToS.PDB.PDBAtom}
        atms = struc
        atmcords = @lift atmcords = [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
        colrs = @lift [atomcolors[x.element] for x in $atms]
        inspectorlabel = (self, i, p) -> "atom: $(atm1.atom)   element: $(atm1.element)   coordinates: $(atm1.coordinates)\noccupancy: $(atm1.occupancy)   B: $(atm1.B)"
    else
        error("plotstruc! not implemented for this type of structure: $(typeof(struc[]))")
    end
    pxwidths = fig.scene.px_area[].widths
    needresize = false
    # the figure needs to be resized if there's a preexisting MSA plot (with default resolution)
    if pxwidths == [1100,400]
        needresize = true
    end
    if plottype == :spacefilling
        markersize = @lift atomradii($atms; radiustype = :vdw) .* markerscale
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, atmcords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    elseif plottype == :ballandstick
        if markersize == 0.0
            markersize = @lift atomradii($atms; radiustype = :cov) .* markerscale .* 0.7
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, atmcords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        bndshapes = @lift bondshapes($struc, selectors...; algo = bonds, distance = distance)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
    elseif plottype == :covalent
        markersize = @lift atomradii($atms; radiustype = :cov) .* markerscale
        if markerscale < 1.0
            bndshapes = @lift bondshapes($struc, selectors...; algo = bonds, distance = distance)
            bndmeshes = @lift normal_mesh.($bndshapes)
            bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
            bmesh.inspectable[] = false
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, atmcords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    else
        println("bad plottype")
    end
    # the window has to be reopened to resize at the moment
    if needresize == true
        fig.scene.px_area[] = HyperRectangle{2, Int64}([0, 0], [pxwidths[1], pxwidths[2]+resolution[2]])
        Makie.update_state_before_display!(fig)
    end
    DataInspector(lscene)
    fig
end
function plotstruc!(fig, struc; kwargs...)
    if !(typeof(struc)<:Observable)
        struc = Observable(struc)
    end
    plotstruc!(fig, struc; kwargs...)
end
"""
    plotstruc(structure)

Create and return a Makie Figure for a protein structural element. 

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
- resolution ---- (800,600)
- gridposition -- (1,1)
- plottype ------ :ballandstick, another option is :spacefilling
- atomcolors ---- elecolors, another option is aquacolors, or define your own dict for atoms like: "N" => :blue
"""
function plotstruc(struc; kwargs...)
	fig = Figure()
    if !(typeof(struc)<:Observable)
        struc = Observable(struc)
    end
    plotstruc!(fig, struc; kwargs...)
end
