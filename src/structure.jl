export atomradii,
       atomradius,
       getinspectorlabel,
       firstlabel,
       atomcolors,
       rescolors,
       atomsizes,
       plottingdata,
       plotstruc!,
       plotstruc             

"""
    atomradii( atoms )

Collect atom radii based on element for plotting.

### Keyword Arguments:
- radiustype --- :ballandstick | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick, :spacefilling
"""
function atomradii(atoms::Vector{T}; radiustype = :ballandstick) where T<:BioStructures.AbstractAtom
	if radiustype == :covalent || radiustype == :cov
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
		return [vanderwaalsradii[BioStructures.element(x)] for x in atoms]
    elseif radiustype == :ballandstick || radiustype == :bas
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	else
        println("radiustype not recognized, using covalent radii")
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	end
end
function atomradii(atoms::Observable{T}; radiustype = :ballandstick) where T<:BioStructures.AbstractAtom
    if radiustype == :covalent || radiustype == :cov
        radii = @lift [covalentradii[BioStructures.element(x)] for x in $atoms]
        return radii
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        radii = @lift [vanderwaalsradii[BioStructures.element(x)] for x in $atoms]
        return radii
    elseif radiustype == :ballandstick || radiustype == :bas
        radii = @lift [covalentradii[BioStructures.element(x)] for x in $atoms]
        return radii
    else
        println("radiustype not recognized, using covalent radii")
        radii = @lift [covalentradii[BioStructures.element(x)] for x in $atoms]
        return radii
    end
end
function atomradii(atoms::Vector{T}; radiustype = :ballandstick) where T<:MIToS.PDB.PDBAtom
	if radiustype == :covalent || radiustype == :cov
		return [covalentradii[x.element] for x in atoms]
	elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
		return [vanderwaalsradii[x.element] for x in atoms]
    elseif radiustype == :ballandstick || radiustype == :bas
		return [covalentradii[x.element] for x in atoms]
	else
        println("radiustype not recognized, using covalent radii")
		return [covalentradii[x.element] for x in atoms]
	end
end
function atomradii(atoms::Observable{T}; radiustype = :ballandstick) where T<:Vector{MIToS.PDB.PDBResidue}
    if radiustype == :covalent || radiustype == :cov
        radii = @lift [covalentradii[x.element] for x in $atoms]
        return radii
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        radii = @lift [vanderwaalsradii[x.element] for x in $atoms]
        return radii
    elseif radiustype == :ballandstick || radiustype == :bas
        radii = @lift [covalentradii[x.element] for x in $atoms]
        return radii
    else
        println("radiustype not recognized, using covalent radii")
        radii = @lift [covalentradii[x.element] for x in $atoms]
        return radii
    end
end

"""
    atomradius( atom )

Collect atom radius based on element for plotting.

### Keyword Arguments:
- radiustype --- :ballandstick | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick, :spacefilling
"""
function atomradius(atom::T; radiustype = :ballandstick) where T<:BioStructures.AbstractAtom
    if radiustype == :covalent || radiustype == :cov
		return covalentradii[BioStructures.element(atom)]
	elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
		return vanderwaalsradii[BioStructures.element(atom)]
    elseif radiustype == :ballandstick || radiustype == :bas
		return covalentradii[BioStructures.element(atom)]
	else
        println("radiustype not recognized, using covalent radii")
		return covalentradii[BioStructures.element(atom)]
	end
end
function atomradius(atom::Observable{T}) where T<:BioStructures.AbstractAtom
    if radiustype == :covalent || radiustype == :cov
        radii = @lift getindex(covalentradii, $atom)
        return radii
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        radii = @lift getindex(vanderwaalsradii, $atom)
        return radii
    elseif radiustype == :ballandstick || radiustype == :bas
        radii = @lift getindex(covalentradii, $atom)
        return radii
    else
        println("radiustype not recognized, using covalent radii")
        radii = @lift getindex(covalentradii, $atom)
        return radii
    end
end
function atomradius(atom::T; radiustype = :ballandstick) where T<:MIToS.PDB.PDBAtom
    if radiustype == :covalent || radiustype == :cov
        return covalentradii[atom.element]
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        return vanderwaalsradii[atom.element]
    elseif radiustype == :ballandstick || radiustype == :bas
		return covalentradii[atom.element]
    else
        println("radiustype not recognized, using covalent radii")
        return covalentradii[atom.element]
    end
end
function atomradius(atom::Observable{T}) where T<:MIToS.PDB.PDBAtom
    if radiustype == :covalent || radiustype == :cov
        radii = @lift getindex(covalentradii, $atom.element)
        return radii
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        radii = @lift getindex(vanderwaalsradii, $atom.element)
        return radii
    elseif radiustype == :ballandstick || radiustype == :bas
        radii = @lift getindex(covalentradii, $atom.element)
        return radii
    else
        println("radiustype not recognized, using covalent radii")
        radii = @lift getindex(covalentradii, $atom.element)
        return radii
    end
end

"""
    getinspectorlabel( structure )
    getinspectorlabel( residues )
    getinspectorlabel( atom )

Get the inspector label function for plotting a 'StructuralElementOrList'.

This function uses 'MIToS.PDB.bestoccupancy' or 'defaultatom' to ensure only one position per atom.
"""
function getinspectorlabel(struc::BioStructures.StructuralElementOrList)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    func = (self, i, p) -> "chain: $((atms[i].residue.chain).id)   " *
    "res: $(atms[i].residue.name)   resid: $(atms[i].residue.number)   index: $(i)\n" *
    "atom: $(atms[i].name)   element: $(atms[i].element)   " *
    "serial: $(atms[i].serial)\ncoordinates: $(atms[i].coords)    B: $(atms[i].temp_factor)"
    return func
end
function getinspectorlabel(resz::Vector{MIToS.PDB.PDBResidue})
    atms = [MIToS.PDB.bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
    func = (self, i, p) -> "atom: $(atms[i].atom)   element: $(atms[i].element)   index: $(i)\n" *
    "coordinates: $(atms[i].coordinates)\n" *
    "occupancy: $(atms[i].occupancy)    B: $(atms[i].B)"
    return func
end
function getinspectorlabel(atms::Vector{MIToS.PDB.PDBAtom})
    func = (self, i, p) -> "atom: $(atms[i].atom)   element: $(atms[i].element)   index: $(i)\n" *
    "coordinates: $(atms[i].coordinates)\n" *
    "occupancy: $(atms[i].occupancy)    B: $(atms[i].B)"
    return func
end
function getinspectorlabel(pdata::AbstractDict)
    func = nothing

    if typeof(pdata[:atoms]) <: Vector{MIToS.PDB.PDBAtom}
        atms = pdata[:atoms]
        func = (self, i, p) -> "atom: $(atms[i].atom)   element: $(atms[i].element)   index: $(i)\n" *
        "coordinates: $(atms[i].coordinates)\n" *
        "occupancy: $(atms[i].occupancy)    B: $(atms[i].B)"
    elseif typeof(pdata[:atoms]) <: Vector{MIToS.PDB.PDBResidue}
        resz = pdata[:atoms]
        atms = [MIToS.PDB.bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
        func = (self, i, p) -> "atom: $(atms[i].atom)   element: $(atms[i].element)   index: $(i)\n" *
        "coordinates: $(atms[i].coordinates)\n" *
        "occupancy: $(atms[i].occupancy)    B: $(atms[i].B)"
    elseif typeof(pdata[:atoms]) <: BioStructures.StructuralElementOrList
        atms = pdata[:atoms]
        atms = defaultatom.(BioStructures.collectatoms(atms))
        func = (self, i, p) -> "chain: $(atms[i].residue.chain.id)   " *
        "res: $(atms[i].residue.name)   resid: $(atms[i].residue.number)   index: $(i)\n" *
        "atom: $(atms[i].name)   element: $(atms[i].element)   " *
        "serial: $(atms[i].serial)\ncoordinates: $(atms[i].coords)    B: $(atms[i].temp_factor)"
    end

    return func
end

"""
    firstlabel( inspectorfunc::Function )

Show an example of the inspector label function looks like. The position `p`
will not be available to this function, so it will be set to `nothing`.
"""
function firstlabel(inspectorfunc::Function)
    println("--- First label ---\n" * (inspectorfunc(1,1,1)) * "\n-------------------")
    return inspectorfunc(1,1,nothing)
end

"""
    atomcolors( atoms )

Get a Vector of colors for the atoms.
To see all default element and amino acid colorschemes, use `getbiocolors()`.
Keyword argument `colors` takes a Dict which maps element to color. ("C" => :red)

This function uses 'MIToS.PDB.bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors
"""
function atomcolors(struc::BioStructures.StructuralElementOrList; colors = elecolors)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    colrs = [colors[BioStructures.element(x)] for x in atms]
    return colrs
end
function atomcolors(struc::Observable{T}; colors = elecolors) where {T<:BioStructures.StructuralElementOrList}
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    colrs = @lift [colors[BioStructures.element(x)] for x in $atms]
    return colrs
end
function atomcolors(resz::Vector{MIToS.PDB.PDBResidue}; colors = elecolors)
    atms = [MIToS.PDB.bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
    colrs = [colors[x.element] for x in atms]
    return colrs
end
function atomcolors(resz::Observable{T}; colors = elecolors) where {T<:Vector{MIToS.PDB.PDBResidue}}
    atms = @lift [MIToS.PDB.bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    colrs = @lift [colors[x.element] for x in $atms]
    return colrs
end
function atomcolors(atms::Vector{MIToS.PDB.PDBAtom}; colors = elecolors)
    colrs = [colors[x.element] for x in atms]
    return colrs
end
function atomcolors(atms::Observable{T}; colors = elecolors) where {T<:Vector{MIToS.PDB.PDBAtom}}
    colrs = @lift [colors[x.element] for x in $atms]
    return colrs
end

"""
    rescolors( residues )

Get a Vector of colors for the atoms.
To see all default element and amino acid colorschemes, use `getbiocolors()`.
Keyword argument `colors` takes a Dict which maps residue to color. ("C" => :red)

This function uses 'MIToS.PDB.bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
"""
function rescolors(struc::BioStructures.StructuralElementOrList; colors = maecolors)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    resnames = [resletterdict[atms[i].residue.name] for i in 1:length(atms)]
    colrs = [colors[resnames[j]] for j in 1:length(resnames)]
    return colrs
end
function rescolors(struc::Observable{T}; colors = maecolors) where {T<:BioStructures.StructuralElementOrList}
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    resnames = @lift [resletterdict[$atms[i].residue.name] for i in 1:length($atms)]
    colrs = @lift [colors[$resnames[j]] for j in 1:length($resnames)]
    return colrs
end
function rescolors(resz::Vector{MIToS.PDB.PDBResidue}; colors = maecolors)
    atms = [MIToS.PDB.bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	resnames = [[resz[i].id.name for j in 1:size(MIToS.PDB.bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
    colrs = [colors[resletterdict[resnames[j]]] for j in 1:length(resnames)]
    return colrs
end
function rescolors(resz::Observable{T}; colors = maecolors) where {T<:Vector{MIToS.PDB.PDBResidue}}
    atms = @lift [MIToS.PDB.bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
	resnames = @lift [[$resz[i].id.name for j in 1:size(MIToS.PDB.bestoccupancy($resz[i].atoms),1)] for i in 1:length($resz)] |> flatten
    colrs = @lift [colors[resletterdict[$resnames[j]]] for j in 1:length($resnames)]
    return colrs
end
function rescolors(atms::Vector{MIToS.PDB.PDBAtom}; colors = maecolors)
    resnames = [atms[i].residue.name for i in 1:length(atms)]
    colrs = [colors[resletterdict[resnames[j]]] for j in 1:length(resnames)]
    return colrs
end
function rescolors(atms::Observable{T}; colors = maecolors) where {T<:Vector{MIToS.PDB.PDBAtom}}
    resnames = @lift [$atms[i].residue.name for i in 1:length($atms)]
    colrs = @lift [colors[resletterdict[$resnames[j]]] for j in 1:length($resnames)]
    return colrs
end

"""
    atomsizes( atms )

Get a Vector of sizes for the atoms from a BioStructures.StructuralElementOrList.

This function uses 'MIToS.PDB.bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- radiustype --- :ballandstick | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick, :spacefilling
"""
function atomsizes(struc::BioStructures.StructuralElementOrList; radiustype = :ballandstick)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    sizes = atomradii(atms; radiustype = radiustype)
    return sizes
end
function atomsizes(struc::Observable{T}; radiustype = :ballandstick) where {T<:BioStructures.StructuralElementOrList}
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    sizes = @lift atomradii($atms; radiustype = radiustype)
    return sizes
end
function atomsizes(resz::Vector{MIToS.PDB.PDBResidue}; radiustype = :ballandstick)
    atms = [MIToS.PDB.bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
    sizes = atomradii(atms; radiustype = radiustype)
    return sizes
end
function atomsizes(resz::Observable{T}; radiustype = :ballandstick) where {T<:Vector{MIToS.PDB.PDBResidue}}
    atms = @lift [MIToS.PDB.bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    sizes = @lift atomradii($atms; radiustype = radiustype)
    return sizes
end
function atomsizes(atms::Vector{MIToS.PDB.PDBAtom}; radiustype = :ballandstick)
    sizes = atomradii(atms; radiustype = radiustype)
    return sizes
end
function atomsizes(atms::Observable{T}; radiustype = :ballandstick) where {T<:Vector{MIToS.PDB.PDBAtom}}
    sizes = @lift atomradii($atms; radiustype = radiustype)
    return sizes
end

"""
	plottingdata( structure )
    plottingdata( residues )
    plottingdata( atoms )

This function returns an OrderedDict of the main data used for plotting. 
This function uses 'MIToS.PDB.bestoccupancy' or 'defaultatom' to ensure only one position per atom.
By default the kwarg 'water' is set to false, so water molecules are not included.

### Returns:
    OrderedDict(:atoms => ..., 
                :coords => ..., 
                :colors => ...,
                :sizes => ...,
                :bonds => ...)

### Keyword Arguments:
- colors ------- elecolors      | Options - elecolors, aquacolors, shapelycolors, maecolors
- radiustype --- :ballandstick  | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick, :spacefilling
- water -------- false          | Options - true, false
"""
function plottingdata(struc::BioStructures.StructuralElementOrList;
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false)
    #
    atms = defaultatom.(BioStructures.collectatoms(struc))
    if water == false
        atms = BioStructures.collectatoms(struc,!waterselector)
    end
    atmcords = coordarray(atms) |> transpose |> collect
    colrs = []
    try
        colrs = to_color.([colors[BioStructures.element(x)] for x in atms])
    catch
        colrs = to_color.(rescolors(struc; colors = colors))
    end
    sizes = atomradii(atms; radiustype = radiustype)
    bonds = getbonds(struc)

    return OrderedDict(:atoms => atms, 
                        :coords => atmcords, 
                        :colors => colrs,
                        :sizes => sizes,
                        :bonds => bonds)
end
function plottingdata(struc::Observable{T};
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false) where {T<:BioStructures.StructuralElementOrList}
    #
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    if water == false
        atms = @lift BioStructures.collectatoms($struc,!waterselector)
    end
    atmcords = @lift coordarray($atms) |> transpose |> collect
    colrs = []
    try
        colrs = @lift to_color.([colors[BioStructures.element(x)] for x in $atms])
    catch
        colrs = @lift to_color.(rescolors($struc; colors = colors))
    end
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bonds = @lift getbonds($struc)

    return OrderedDict(:atoms => atms, 
                        :coords => atmcords, 
                        :colors => colrs,
                        :sizes => sizes,
                        :bonds => bonds)
end
function plottingdata(resz::Vector{MIToS.PDB.PDBResidue};
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false)
    #
    atms = [MIToS.PDB.bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
    atmcords = [[atms[i].coordinates[1],atms[i].coordinates[2],atms[i].coordinates[3]] for i in 1:length(atms)] |> combinedims |> transpose |> collect
    colrs = []
    try
        colrs = to_color.([colors[x.element] for x in atms])
    catch
        colrs = to_color.(rescolors(resz; colors = colors))
    end
    sizes = atomradii(atms; radiustype = radiustype)
    bonds = getbonds(resz)

    return OrderedDict(:atoms => atms, 
                        :coords => atmcords, 
                        :colors => colrs,
                        :sizes => sizes,
                        :bonds => bonds)
end
function plottingdata(resz::Observable{T};
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false) where {T<:Vector{MIToS.PDB.PDBResidue}}
    #
    atms = @lift [MIToS.PDB.bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    atmcords = @lift [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
    colrs = []
    try
        colrs = @lift to_color.([colors[x.element] for x in $atms])
    catch
        colrs = @lift to_color.(rescolors($resz; colors = colors))
    end
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bonds = @lift getbonds($resz)

    return OrderedDict(:atoms => atms, 
                        :coords => atmcords, 
                        :colors => colrs,
                        :sizes => sizes,
                        :bonds => bonds)
end
function plottingdata(atms::Vector{MIToS.PDB.PDBAtom};
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false)
    #
    atmcords = [[atms[i].coordinates[1],atms[i].coordinates[2],atms[i].coordinates[3]] for i in 1:length(atms)] |> combinedims |> transpose |> collect
    colrs = to_color.([colors[x.element] for x in atms])
    sizes = atomradii(atms; radiustype = radiustype)
    bnds = getbonds(atms)

    return OrderedDict(:atoms => atms, 
                        :coords => atmcords, 
                        :colors => colrs,
                        :sizes => sizes,
                        :bonds => bnds)
end
function plottingdata(atms::Observable{T};
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false) where {T<:Vector{MIToS.PDB.PDBAtom}}
    #
    atmcords = @lift atmcords = [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
    colrs = @lift to_color.([colors[x.element] for x in $atms])
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bnds = @lift getbonds($atms)

    return OrderedDict(:atoms => atms, 
                        :coords => atmcords, 
                        :colors => colrs,
                        :sizes => sizes,
                        :bonds => bnds)
end
function plottingdata(pdata::AbstractDict; kwargs...)
    return pdata
end
function plottingdata(pdata::Observable{T}; kwargs...) where {T<:AbstractDict}
    return pdata
end

"""
    plotstruc!( fig, structure )
    plotstruc!( gridposition, structure )
    plotstruc!( fig, plotdata )
    plotstruc!( gridposition, plotdata )

Plot a protein structure(/chain/residues/atoms) into a Figure. 

# Examples
```julia
fig = Figure()

using MIToS.PDB

pdbfile = MIToS.PDB.downloadpdb("2vb1")
struc = MIToS.PDB.read(pdbfile, PDBML) |> Observable
strucplot = plotstruc!(fig, struc)

chain_A = @residues struc model "1" chain "A" group "ATOM" residue All
strucplot = plotstruc!(fig, chain_A)

chnatms = @atoms struc model "1" chain "A" group "ATOM" residue All atom All
strucplot = plotstruc!(fig, chnatms)
-------------------------
using BioStructures

struc = retrievepdb("2vb1", dir = "data/") |> Observable
strucplot = plotstruc!(fig, struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
strucplot = plotstruc!(fig, struc)

chain_A = retrievepdb("2vb1", dir = "data/")["A"] |> Observable
strucplot = plotstruc!(fig, chain_A)
```

### Keyword Arguments:
- resolution ----- (420,600)
- gridposition --- (1,1)  # if an MSA is already plotted, (2,1:3) works well
- plottype ------- :ballandstick, :covalent, or :spacefilling
- atomcolors ----- elecolors, others in `getbiocolors()`, or provide a Dict like: "N" => :blue
- markersize ----- 0.0
- markerscale ---- 1.0
- bondtype ------- :knowledgebased, :covalent, or :distance
- distance ------- 1.9  # distance cutoff for covalent bonds
- inspectorlabel - :default, or define your own function like: (self, i, p) -> "atom: ... coords: ..."
- water ---------- false  # show water molecules
- kwargs... ------ keyword arguments passed to the atom `meshscatter`
"""
function plotstruc!(fig::Figure, struc::T; kwargs...) where {T<:Union{Vector{MIToS.PDB.PDBAtom}, 
                                                    Vector{MIToS.PDB.PDBResidue}, 
                                                    BioStructures.StructuralElementOrList}}
    strucobs = Observable(struc)
    plotstruc!(fig, strucobs; kwargs...)
end
function plotstruc!(figposition::GridPosition, struc::T; kwargs...) where {T<:Union{Vector{MIToS.PDB.PDBAtom}, 
                                                    Vector{MIToS.PDB.PDBResidue}, 
                                                    BioStructures.StructuralElementOrList}}
    strucobs = Observable(struc)
    plotstruc!(figposition, strucobs; kwargs...)
end
function plotstruc!(fig::Figure, struc::Observable;
                    resolution = (420,600),
                    gridposition = (1,1),
                    plottype = :ballandstick,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :knowledgebased,
                    distance = 1.9,
                    inspectorlabel = :default,
                    water = false,
                    kwargs...
                    )
	#
    plotdata = @lift plottingdata($struc; colors = atomcolors, radiustype = plottype, water = water)
    atms = @lift $plotdata[:atoms]
    cords = @lift $plotdata[:coords]
    colrs = @lift $plotdata[:colors]
    sizs = @lift $plotdata[:sizes]
    bnds = @lift $plotdata[:bonds]

    pxwidths = fig.scene.px_area[].widths
    needresize = false
    # the figure needs to be resized if there's a preexisting MSA plot (with default resolution)
    if pxwidths == [1100,400]
        needresize = true
    end
    if inspectorlabel == :default
        inspectorlabel = @lift getinspectorlabel($struc)        
    end
    if plottype == :spacefilling || plottype == :vanderwaals || plottype == :vdw
        markersize = @lift $sizs .* markerscale
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    elseif plottype == :ballandstick || plottype == :bas
        if markersize == 0.0
            markersize = @lift $sizs .* markerscale .* 0.7
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        if bnds == nothing
            bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
    elseif plottype == :covalent || plottype == :cov
        markersize = @lift $sizs .* markerscale
        if markerscale < 1.0
            if bnds == nothing
                bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
            end
            bndshapes = @lift bondshapes($cords, $bnds)
            bndmeshes = @lift normal_mesh.($bndshapes)
            bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
            bmesh.inspectable[] = false
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    else
        ArgumentError("bad plottype kwarg")
    end
    # the window has to be reopened to resize at the moment
    if needresize == true
        fig.scene.px_area[] = HyperRectangle{2, Int64}([0, 0], [pxwidths[1], pxwidths[2]+resolution[2]])
        Makie.update_state_before_display!(fig)
    end
    DataInspector(lscene)
    fig
end
function plotstruc!(figposition::GridPosition, struc::Observable;
                    resolution = (420,600),
                    gridposition = (1,1),
                    plottype = :ballandstick,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :knowledgebased,
                    distance = 1.9,
                    inspectorlabel = :default,
                    water = false,
                    kwargs...
                    )
	#
    plotdata = plottingdata(struc; colors = atomcolors, radiustype = plottype, water = water)
    atms = plotdata[:atoms]
    cords = plotdata[:coords]
    colrs = plotdata[:colors]
    sizs = plotdata[:sizes]
    bnds = plotdata[:bonds]

    if inspectorlabel == :default
        inspectorlabel = @lift getinspectorlabel($struc)        
    end
    if plottype == :spacefilling || plottype == :vanderwaals || plottype == :vdw
        markersize = @lift $sizs .* markerscale
        lscene = LScene(figposition; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    elseif plottype == :ballandstick || plottype == :bas
        if markersize == 0.0
            markersize = @lift $sizs .* markerscale .* 0.7
        end
        lscene = LScene(figposition; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        if bnds == nothing || typeof(bnds)<:Observable
            bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
    elseif plottype == :covalent || plottype == :cov
        markersize = @lift $sizs .* markerscale
        if bnds == nothing || typeof(bnds)<:Observable
            bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
        lscene = LScene(figposition; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    else
        ArgumentError("bad plottype kwarg")
    end

    DataInspector(lscene)
    fig
end
function plotstruc!(fig::Figure, plotdata::AbstractDict{Symbol,T};
                    resolution = (420,600),
                    gridposition = (1,1),
                    plottype = :ballandstick,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :knowledgebased,
                    distance = 1.9,
                    inspectorlabel = :default,
                    water = false,
                    kwargs...
                    ) where {T}
	#
    atms = []
    cords = []
    colrs = []
    sizs = []
    bnds = []

    if T<:Observable
        atms = plotdata[:atoms]
        cords = plotdata[:coords]
        colrs = plotdata[:colors]
        sizs = plotdata[:sizes]
        bnds = plotdata[:bonds]
    else
        atms = plotdata[:atoms] |> Observable
        cords = plotdata[:coords] |> Observable
        colrs = plotdata[:colors] |> Observable
        sizs = plotdata[:sizes] |> Observable
        bnds = plotdata[:bonds] |> Observable
    end

    pxwidths = fig.scene.px_area[].widths
    needresize = false
    # the figure needs to be resized if there's a preexisting MSA plot (with default resolution)
    if pxwidths == [1100,400]
        needresize = true
    end
    if inspectorlabel == :default
        inspectorlabel = @lift getinspectorlabel($atms)        
    end
    if plottype == :spacefilling || plottype == :vanderwaals || plottype == :vdw
        markersize = @lift $sizs .* markerscale
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    elseif plottype == :ballandstick || plottype == :bas
        if markersize == 0.0
            markersize = @lift $sizs .* markerscale .* 0.7
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        if bnds == nothing || typeof(bnds)<:Observable
            bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
    elseif plottype == :covalent || plottype == :cov
        markersize = @lift $sizs .* markerscale
        if bnds == nothing || typeof(bnds)<:Observable
            bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    else
        ArgumentError("bad plottype kwarg")
    end
    # the window has to be reopened to resize at the moment
    if needresize == true
        fig.scene.px_area[] = HyperRectangle{2, Int64}([0, 0], [pxwidths[1], pxwidths[2]+resolution[2]])
        Makie.update_state_before_display!(fig)
    end
    DataInspector(lscene)
    fig
end
function plotstruc!(figposition::GridPosition, plotdata::AbstractDict{Symbol,T};
                    resolution = (420,600),
                    gridposition = (1,1),
                    plottype = :ballandstick,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :knowledgebased,
                    distance = 1.9,
                    inspectorlabel = :default,
                    water = false,
                    kwargs...
                    ) where {T}
	#
    atms = []
    cords = []
    colrs = []
    sizs = []
    bnds = []

    if T<:Observable
        atms = plotdata[:atoms]
        cords = plotdata[:coords]
        colrs = plotdata[:colors]
        sizs = plotdata[:sizes]
        bnds = plotdata[:bonds]
    else
        atms = plotdata[:atoms] |> Observable
        cords = plotdata[:coords] |> Observable
        colrs = plotdata[:colors] |> Observable
        sizs = plotdata[:sizes] |> Observable
        bnds = plotdata[:bonds] |> Observable
    end

    if inspectorlabel == :default
        inspectorlabel = @lift getinspectorlabel($atms)        
    end
    if plottype == :spacefilling || plottype == :vanderwaals || plottype == :vdw
        markersize = @lift $sizs .* markerscale
        lscene = LScene(figposition; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    elseif plottype == :ballandstick || plottype == :bas
        if markersize == 0.0
            markersize = @lift $sizs .* markerscale .* 0.7
        end
        lscene = LScene(figposition; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        if bnds == nothing || typeof(bnds)<:Observable
            bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
    elseif plottype == :covalent || plottype == :cov
        markersize = @lift $sizs .* markerscale
        if bnds == nothing || typeof(bnds)<:Observable
            bnds = @lift getbonds($atms; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
        lscene = LScene(figposition; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    else
        ArgumentError("bad plottype kwarg")
    end

    DataInspector(lscene)
    fig
end

"""
    plotstruc( structure )
    plotstruc( residues )
    plotstruc( plotdata )

Create and return a Makie Figure for a protein structural element. 

# Examples
```julia
using MIToS.PDB

pdbfile = MIToS.PDB.downloadpdb("2vb1")
struc = MIToS.PDB.read(pdbfile, PDBML) |> Observable
strucplot = plotstruc(struc)

chain_A = @residues struc model "1" chain "A" group "ATOM" residue All
strucplot = plotstruc(chain_A)

chnatms = @atoms struc model "1" chain "A" group "ATOM" residue All atom All
strucplot = plotstruc(chnatms)
-------------------------
using BioStructures

struc = retrievepdb("2vb1", dir = "data/") |> Observable
strucplot = plotstruc(struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
strucplot = plotstruc(struc)

chain_A = retrievepdb("2hhb", dir = "data/")["A"] |> Observable
strucplot = plotstruc(chain_A)
```

### Keyword Arguments:
- resolution ----- (420,600)
- gridposition --- (1,1)  # if an MSA is already plotted, (2,1:3) works well
- plottype ------- :ballandstick, :covalent, or :spacefilling
- atomcolors ----- elecolors, others in `getbiocolors()`, or provide a Dict like: "N" => :blue
- markersize ----- 0.0
- markerscale ---- 1.0
- bondtype ------- :knowledgebased, :covalent, or :distance
- distance ------- 1.9  # distance cutoff for covalent bonds
- inspectorlabel - :default, or define your own function like: (self, i, p) -> "atom: ... coords: ..."
- water ---------- false  # show water molecules
- kwargs... ------ keyword arguments passed to the atom `meshscatter`
"""
function plotstruc(struc; resolution = (420,600), kwargs...)
	fig = Figure(resolution = resolution)
    plotstruc!(fig, Observable(struc); kwargs...)
end
function plotstruc(struc::Observable; resolution = (420,600), kwargs...)
	fig = Figure(resolution = resolution)
    plotstruc!(fig, struc; kwargs...)
end
function plotstruc(plotdata::T; resolution = (420,600), kwargs...) where {T<:AbstractDict}
	fig = Figure(resolution = resolution)
    plotstruc!(fig, plotdata; kwargs...)
end
