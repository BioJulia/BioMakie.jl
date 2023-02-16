export atomradii,
       atomradius,
       plotstruc!,
       plotstruc             

"""
    atomradii( atoms::Vector{T} ) where T<:BioStructures.AbstractAtom

Collect atom radii based on element for plotting, from a Vector of BioStructures.AbstractAtoms.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomradii(atoms::Vector{T}; radiustype = :covalent) where T<:BioStructures.AbstractAtom
	if radiustype == :covalent || radiustype == :cov
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	elseif radiustype == :vanderwaals || radiustype == :vdw
		return [vanderwaalsradii[BioStructures.element(x)] for x in atoms]
    elseif radiustype == :ballandstick || radiustype == :bas
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	else
        println("radiustype not recognized, using covalent radii")
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	end
end

"""
    atomradii( atoms::Vector{T} ) where T<:MIToS.PDB.PDBAtom

Collect atom radii based on element for plotting, from a Vector of MIToS.PDB.PDBAtoms.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomradii(atoms::Vector{T}; radiustype = :covalent) where T<:MIToS.PDB.PDBAtom
	if radiustype == :covalent || radiustype == :cov
		return [covalentradii[x.element] for x in atoms]
	elseif radiustype == :vanderwaals || radiustype == :vdw
		return [vanderwaalsradii[x.element] for x in atoms]
    elseif radiustype == :ballandstick || radiustype == :bas
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	else
        println("radiustype not recognized, using covalent radii")
		return [covalentradii[x.element] for x in atoms]
	end
end

"""
    atomradius( atom::BioStructures.Atom )

Collect atom radius based on element for plotting.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomradius(atom::T; radiustype = :covalent) where T<:BioStructures.AbstractAtom
    if radiustype == :covalent || radiustype == :cov
		return covalentradii[BioStructures.element(atom)]
	elseif radiustype == :vanderwaals || radiustype == :vdw
		return vanderwaalsradii[BioStructures.element(atom)]
    elseif radiustype == :ballandstick || radiustype == :bas
		return covalentradii[BioStructures.element(atom)]
	else
        println("radiustype not recognized, using covalent radii")
		return covalentradii[BioStructures.element(atom)]
	end
end

"""
    atomradius( atom::MIToS.PDB.PDBAtom )

Collect atom radius based on element for plotting.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomradius(atom::T; radiustype = :covalent) where T<:MIToS.PDB.PDBAtom
    if radiustype == :covalent || radiustype == :cov
        return covalentradii[atom.element]
    elseif radiustype == :vanderwaals || radiustype == :vdw
        return vanderwaalsradii[atom.element]
    elseif radiustype == :ballandstick || radiustype == :bas
		return covalentradii[atom.element]
    else
        println("radiustype not recognized, using covalent radii")
        return covalentradii[atom.element]
    end
end

"""
    inspectorlabel( struc::BioStructures.StructuralElementOrList )

Get the inspector label function for plotting a BioStructures.StructuralElementOrList.
(ProteinStructure, Model, Chain, Residue, Atom, and lists of these)
"""
function inspectorlabel(struc::BioStructures.StructuralElementOrList)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    func = (self, i, p) -> "chain: $((atms[i].residue.chain).id)   " *
    "res: $(atms[i].residue.name)   number: $(atms[i].residue.number)   index: $(i)\n" *
    "atom: $(atms[i].name)   element: $(atms[i].element)   " *
    "serial: $(atms[i].serial)\ncoordinates: $(atms[i].coords)    B: $(atms[i].temp_factor)"
    return func
end

"""
    inspectorlabel( resz::Vector{MIToS.PDB.PDBResidue} )

Get the inspector label function for plotting a Vector of MIToS.PDB.PDBResidues.
"""
function inspectorlabel(resz::Vector{MIToS.PDB.PDBResidue})
    atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
    func = (self, i, p) -> "atom: $(atms[i].atom)   element: $(atms[i].element)   index: $(i)\n" *
    "coordinates: $(atms[i].coordinates)\n" *
    "occupancy: $(atms[i].occupancy)    B: $(atms[i].B)"
    return func
end

"""
    inspectorlabel( atms::Vector{MIToS.PDB.PDBAtom} )

Get the inspector label function for plotting a vector of MIToS.PDB.PDBAtoms.
"""
function inspectorlabel(atms::Vector{MIToS.PDB.PDBAtom})
    func = (self, i, p) -> "atom: $(atms[i].atom)   element: $(atms[i].element)   index: $(i)\n" *
    "coordinates: $(atms[i].coordinates)\n" *
    "occupancy: $(atms[i].occupancy)    B: $(atms[i].B)"
    return func
end

"""
    inspectorlabel( struc::Observable{T} ) where {T<:BioStructures.StructuralElementOrList}

Get the inspector label function for plotting a BioStructures StructuralElementOrList.
(ProteinStructure, Model, Chain, Residue, Atom, and lists of these)
"""
function inspectorlabel(struc::Observable{T}) where {T<:BioStructures.StructuralElementOrList}
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    func = @lift (self, i, p) -> "chain: $(($atms[i].residue.chain).id)   " *
    "res: $($atms[i].residue.name)   number: $($atms[i].residue.number)   index: $(i)\n" *
    "atom: $($atms[i].name)   element: $($atms[i].element)   " *
    "serial: $($atms[i].serial)\ncoordinates: $($atms[i].coords)    B: $($atms[i].temp_factor)"
    return func
end

"""
    inspectorlabel( resz::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBResidue}}

Get the inspector label function for plotting a vector of MIToS.PDB.PDBResidues.
"""
function inspectorlabel(resz::Observable{T}) where {T<:Vector{MIToS.PDB.PDBResidue}}
    atms = @lift [bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    func = @lift (self, i, p) -> "atom: $($atms[i].atom)   element: $($atms[i].element)   index: $(i)\n" *
    "coordinates: $($atms[i].coordinates)\n" *
    "occupancy: $($atms[i].occupancy)    B: $($atms[i].B)"
    return func
end

"""
    inspectorlabel( atms::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBAtom}}

Get the inspector label function for plotting a vector of MIToS.PDB.PDBAtoms.
"""
function inspectorlabel(atms::Observable{T}) where {T<:Vector{MIToS.PDB.PDBAtom}}
    func = @lift (self, i, p) -> "atom: $($atms[i].atom)   element: $($atms[i].element)   index: $(i)\n" *
    "coordinates: $($atms[i].coordinates)\n" *
    "occupancy: $($atms[i].occupancy)    B: $($atms[i].B)"
    return func
end

"""
    firstlabel( inspectorfunc::Observable{T} )

Show an example of the inspector label function looks like. The position `p`
will not be available to this function, so it will be set to `nothing`.
"""
function firstlabel(inspectorfunc::Observable{T}) where {T<:Function}
    println("--- First label ---\n" * (inspectorfunc[](1,1,1)) * "\n-------------------")
    return inspectorfunc[](1,1,nothing)
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
    atomcolors( struc::BioStructures.StructuralElementOrList )

Get a Vector of colors for the atoms in a BioStructures StructuralElementOrList.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps element to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors
"""
function atomcolors(struc::BioStructures.StructuralElementOrList; colors = elecolors)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    colrs = [colors[BioStructures.element(x)] for x in atms]
    return colrs
end

"""
    atomcolors( resz::Vector{MIToS.PDB.PDBResidue} )

Get a Vector of colors for the atoms from a Vector of MIToS.PDB.PDBResidue.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps element to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors
"""
function atomcolors(resz::Vector{MIToS.PDB.PDBResidue}; colors = elecolors)
    atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
    colrs = [colors[x.element] for x in atms]
    return colrs
end

"""
    atomcolors( atms::Vector{MIToS.PDB.PDBAtom} )

Get a Vector of colors for the atoms from a Vector of MIToS.PDB.PDBAtom.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps element to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors
"""
function atomcolors(atms::Vector{MIToS.PDB.PDBAtom}; colors = elecolors)
    colrs = [colors[x.element] for x in atms]
    return colrs
end

"""
    atomcolors( struc::Observable{T} ) where {T<:BioStructures.StructuralElementOrList}

Get a Vector of colors for the atoms in a BioStructures StructuralElementOrList.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps element to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors
"""
function atomcolors(struc::Observable{T}; colors = elecolors) where {T<:BioStructures.StructuralElementOrList}
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    colrs = @lift [colors[BioStructures.element(x)] for x in $atms]
    return colrs
end

"""
    atomcolors( resz::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBResidue}}

Get a Vector of colors for the atoms from a Vector of MIToS.PDB.PDBResidues.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps element to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors
"""
function atomcolors(resz::Observable{T}; colors = elecolors) where {T<:Vector{MIToS.PDB.PDBResidue}}
    atms = @lift [bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    colrs = @lift [colors[x.element] for x in $atms]
    return colrs
end

"""
    atomcolors( atms::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBAtom}}

Get a Vector of colors for the atoms from a Vector of MIToS.PDB.PDBAtoms.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps element to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors
"""
function atomcolors(atms::Observable{T}; colors = elecolors) where {T<:Vector{MIToS.PDB.PDBAtom}}
    colrs = @lift [colors[x.element] for x in $atms]
    return colrs
end

"""
    rescolors( struc::BioStructures.StructuralElementOrList )

Get a Vector of colors for the atoms from a BioStructures.StructuralElementOrList.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps residue to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
"""
function rescolors(struc::BioStructures.StructuralElementOrList; colors = maecolors)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    resnames = [resletterdict[atms[i].residue.name] for i in 1:length(atms)]
    colrs = [colors[resnames[j]] for j in 1:length(resnames)]
    return colrs
end

"""
    rescolors( resz::Vector{MIToS.PDB.PDBResidue} )

Get a Vector of colors for the atoms from a Vector of MIToS.PDB.PDBResidues.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps residue to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
"""
function rescolors(resz::Vector{MIToS.PDB.PDBResidue}; colors = maecolors)
    atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	resindices = [[i for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	resnames = [[resz[i].id.name for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
    colrs = [colors[resnames[j]] for j in 1:length(resnames)]
    return colrs
end

"""
    rescolors( struc::Observable{T} ) where {T<:BioStructures.StructuralElementOrList}

Get a Vector of colors for the atoms from a BioStructures.StructuralElementOrList.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps residue to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
"""
function rescolors(struc::Observable{T}; colors = maecolors) where {T<:BioStructures.StructuralElementOrList}
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    resnames = @lift [resletterdict[$atms[i].residue.name] for i in 1:length($atms)]
    colrs = @lift [colors[$resnames[j]] for j in 1:length($resnames)]
    return colrs
end

"""
    rescolors( resz::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBResidue}}

Get a Vector of colors for the atoms from a Vector of MIToS.PDB.PDBResidues.
To see all default element and amino acid colorschemes, use the `getbiocolors()` function.
Keyword argument `colors` takes a Dict which maps residue to color. ("C" => :red)

### Keyword Arguments:
- colors --- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
"""
function rescolors(resz::Observable{T}; colors = maecolors) where {T<:Vector{MIToS.PDB.PDBResidue}}
    atms = @lift [bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
	resindices = @lift [[i for j in 1:size(bestoccupancy($resz[i].atoms),1)] for i in 1:length($resz)] |> flatten
	resnames = @lift [[$resz[i].id.name for j in 1:size(bestoccupancy($resz[i].atoms),1)] for i in 1:length($resz)] |> flatten
    colrs = @lift [colors[$resnames[j]] for j in 1:length($resnames)]
    return colrs
end

"""
    atomsizes( struc::BioStructures.StructuralElementOrList )

Get a Vector of sizes for the atoms from a BioStructures.StructuralElementOrList.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomsizes(struc::BioStructures.StructuralElementOrList; radiustype = :covalent)
    atms = defaultatom.(BioStructures.collectatoms(struc))
    sizes = atomradii(atms; radiustype = radiustype)
    return sizes
end

"""
    atomsizes( resz::Vector{MIToS.PDB.PDBResidue} )

Get a Vector of sizes for the atoms from a Vector of MIToS.PDB.PDBResidues.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomsizes(resz::Vector{MIToS.PDB.PDBResidue}; radiustype = :covalent)
    atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
    sizes = atomradii(atms; radiustype = radiustype)
    return sizes
end

"""
    atomsizes( atms::Vector{MIToS.PDB.PDBAtom} )

Get a Vector of sizes for the atoms from a Vector of MIToS.PDB.PDBAtoms.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomsizes(atms::Vector{MIToS.PDB.PDBAtom}; radiustype = :covalent)
    sizes = atomradii(atms; radiustype = radiustype)
    return sizes
end

"""
    atomsizes( struc::Observable{T} ) where {T<:BioStructures.StructuralElementOrList}

Get a Vector of sizes for the atoms from a BioStructures.StructuralElementOrList.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomsizes(struc::Observable{T}; radiustype = :covalent) where {T<:BioStructures.StructuralElementOrList}
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    sizes = @lift atomradii($atms; radiustype = radiustype)
    return sizes
end

"""
    atomsizes( resz::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBResidue}}

Get a Vector of sizes for the atoms from a Vector of MIToS.PDB.PDBResidues.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomsizes(resz::Observable{T}; radiustype = :covalent) where {T<:Vector{MIToS.PDB.PDBResidue}}
    atms = @lift [bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    sizes = @lift atomradii($atms; radiustype = radiustype)
    return sizes
end

"""
    atomsizes( atms::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBAtom}}

Get a Vector of sizes for the atoms from a Vector of MIToS.PDB.PDBAtoms.

### Keyword Arguments:
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function atomsizes(atms::Observable{T}; radiustype = :covalent) where {T<:Vector{MIToS.PDB.PDBAtom}}
    sizes = @lift atomradii($atms; radiustype = radiustype)
    return sizes
end

"""
	plottingdata( struc::BioStructures.StructuralElementOrList )

Collects data for plotting from a BioStructures.StructuralElementOrList.
This function returns an OrderedDict of Observables that are the main data
used for plotting, for ease of use and consistency. 

    OrderedDict("atoms" => ..., 
                "coords" => ..., 
                "colors" => ...,
                "sizes" => ...,
                "bonds" => ...)

### Keyword Arguments:
- colors ------- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function plottingdata(struc::BioStructures.StructuralElementOrList;
                        colors = elecolors,
                        radiustype = :covalent)
    #
    struc = Observable(struc)
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    atmcords = @lift coordarray($atms) |> transpose |> collect
    try
        colrs = @lift [colors[BioStructures.element(x)] for x in $atms]
    catch
        colrs = @lift rescolors($struc; colors = colors)
    end
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bonds = @lift getbonds($struc)

    return OrderedDict("atoms" => atms, 
                        "coords" => atmcords, 
                        "colors" => colrs,
                        "sizes" => sizes,
                        "bonds" => bonds)
end

"""
	plottingdata( resz::Vector{MIToS.PDB.PDBResidue} )

Collects data for plotting from a Vector of MIToS.PDB.PDBResidues.
This function returns an OrderedDict of Observables that are the main data
used for plotting, for ease of use and consistency. 

    OrderedDict("atoms" => ..., 
                "coords" => ..., 
                "colors" => ...,
                "sizes" => ...,
                "bonds" => ...)

### Keyword Arguments:
- colors ------- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function plottingdata(resz::Vector{MIToS.PDB.PDBResidue};
                        colors = elecolors,
                        radiustype = :covalent)
    #
    resz = Observable(resz)
    atms = @lift [bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    atmcords = @lift atmcords = [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
    colrs = @lift [colors[x.element] for x in $atms]
    try
        colrs = @lift [colors[x.element] for x in $atms]
    catch
        colrs = @lift rescolors($struc; colors = colors)
    end
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bonds = @lift getbonds($resz)

    return OrderedDict("atoms" => atms, 
                        "coords" => atmcords, 
                        "colors" => colrs,
                        "sizes" => sizes,
                        "bonds" => bonds)
end

"""
	plottingdata( atms::Vector{MIToS.PDB.PDBAtom} )

Collects data for plotting from a Vector of MIToS.PDB.PDBAtoms.
This function returns an OrderedDict of Observables that are the main data
used for plotting, for ease of use and consistency. 

    OrderedDict("atoms" => ..., 
                "coords" => ..., 
                "colors" => ...,
                "sizes" => ...,
                "bonds" => nothing)

### Keyword Arguments:
- colors ------- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function plottingdata(atms::Vector{MIToS.PDB.PDBAtom};
                        colors = elecolors,
                        radiustype = :covalent)
    #
    atms = Observable(atms)
    atmcords = @lift atmcords = [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
    colrs = @lift [colors[x.element] for x in $atms]
    sizes = @lift atomradii($atms; radiustype = radiustype)

    return OrderedDict("atoms" => atms, 
                        "coords" => atmcords, 
                        "colors" => colrs,
                        "sizes" => sizes,
                        "bonds" => nothing)
end

"""
	plottingdata( struc::Observable{T} ) where {T<:BioStructures.StructuralElementOrList}

Collects data for plotting from a BioStructures.StructuralElementOrList.
This function returns an OrderedDict of Observables that are the main data
used for plotting, for ease of use and consistency. 

    OrderedDict("atoms" => ..., 
                "coords" => ..., 
                "colors" => ...,
                "sizes" => ...,
                "bonds" => ...)

### Keyword Arguments:
- colors ------- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function plottingdata(struc::Observable{T};
                        colors = elecolors,
                        radiustype = :covalent) where {T<:BioStructures.StructuralElementOrList}
    #
    atms = @lift defaultatom.(BioStructures.collectatoms($struc))
    atmcords = @lift coordarray($atms) |> transpose |> collect
    try
        colrs = @lift [colors[BioStructures.element(x)] for x in $atms]
    catch
        colrs = @lift rescolors($struc; colors = colors)
    end
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bonds = @lift getbonds($struc)

    return OrderedDict("atoms" => atms, 
                        "coords" => atmcords, 
                        "colors" => colrs,
                        "sizes" => sizes,
                        "bonds" => bonds)
end

"""
	plottingdata( resz::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBResidue}}

Collects data for plotting from a Vector of MIToS.PDB.PDBResidues.
This function returns an OrderedDict of Observables that are the main data
used for plotting, for ease of use and consistency. 

    OrderedDict("atoms" => ..., 
                "coords" => ..., 
                "colors" => ...,
                "sizes" => ...,
                "bonds" => ...)

### Keyword Arguments:
- colors ------- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function plottingdata(resz::Observable{T};
                        colors = elecolors,
                        radiustype = :covalent) where {T<:Vector{MIToS.PDB.PDBResidue}}
    #
    atms = @lift [bestoccupancy($resz[i].atoms) for i in 1:length($resz)] |> flatten
    atmcords = @lift atmcords = [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
    try
        colrs = @lift [colors[x.element] for x in $atms]
    catch
        colrs = @lift rescolors($struc; colors = colors)
    end
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bonds = @lift getbonds($resz)

    return OrderedDict("atoms" => atms, 
                        "coords" => atmcords, 
                        "colors" => colrs,
                        "sizes" => sizes,
                        "bonds" => bonds)
end

"""
	plottingdata( atms::Observable{T} ) where {T<:Vector{MIToS.PDB.PDBAtom}}

Collects data for plotting from a Vector of MIToS.PDB.PDBAtoms.
This function returns an OrderedDict of Observables that are the main data
used for plotting, for ease of use and consistency. 

    OrderedDict("atoms" => ..., 
                "coords" => ..., 
                "colors" => ...,
                "sizes" => ...,
                "bonds" => nothing)

### Keyword Arguments:
- colors ------- elecolors | Options - elecolors, aquacolors, shapelycolors, maecolors
- radiustype --- :covalent | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick
"""
function plottingdata(atms::Observable{T};
                        colors = elecolors,
                        radiustype = :covalent) where {T<:Vector{MIToS.PDB.PDBAtom}}
    #
    atmcords = @lift atmcords = [[$atms[i].coordinates[1],$atms[i].coordinates[2],$atms[i].coordinates[3]] for i in 1:length($atms)] |> combinedims |> transpose |> collect
    colrs = @lift [colors[x.element] for x in $atms]
    sizes = @lift atomradii($atms; radiustype = radiustype)

    return OrderedDict("atoms" => atms, 
                        "coords" => atmcords, 
                        "colors" => colrs,
                        "sizes" => sizes,
                        "bonds" => nothing)
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

### Keyword Arguments:
- resolution ----- (800,600)
- gridposition --- (1,1)  # if an MSA is already plotted, (2,1:3) works well
- plottype ------- :covalent, :ballandstick, or :spacefilling
- atomcolors ----- elecolors, others in `getbiocolors`, or provide a dict for atoms/residues like: "N" => :blue
- markersize ----- 0.0
- markerscale ---- 1.0
- bondtype ------- :knowledgebased, :covalent, or :distance
- distance ------- 1.9  # distance cutoff for covalent bonds
- inspectorlabel - :default, or define your own function like: (self, i, p) -> "atom: ... coords: ..."
- kwargs... ------ keyword arguments passed to the atom `meshscatter`

"""
function plotstruc!(fig::Figure, struc::Observable;
                    resolution = (800,600),
                    gridposition = (1,1),
                    plottype = :covalent,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :knowledgebased,
                    distance = 1.9,
                    inspectorlabel = :default,
                    kwargs...
                    )
	#
    plotdata = @lift plottingdata($struc; colors = atomcolors, radiustype = plottype)
    pxwidths = fig.scene.px_area[].widths
    needresize = false
    # the figure needs to be resized if there's a preexisting MSA plot (with default resolution)
    if pxwidths == [1100,400]
        needresize = true
    end
    if inspectorlabel == :default
        inspectorlabel = @lift inspectorlabel($struc)        
    end
    if plottype == :spacefilling || plottype == :vanderwaals || plottype == :vdw
        markersize = @lift $(plotdata["sizes"]) .* markerscale
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, plotdata["coords"]; color = plotdata["colors"], markersize = markersize, inspector_label = inspectorlabel, kwargs...)
    elseif plottype == :ballandstick || plottype == :bas
        if markersize == 0.0
            markersize = @lift $(plotdata["sizes"]) .* markerscale .* 0.7
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, plotdata["coords"]; color = plotdata["colors"], markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        bndshapes = @lift bondshapes($struc; algo = bondtype, distance = distance)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
    elseif plottype == :covalent || plottype == :cov
        markersize = @lift $(plotdata["sizes"]) .* markerscale
        if markerscale < 1.0
            bndshapes = @lift bondshapes($struc; algo = bondtype, distance = distance)
            bndmeshes = @lift normal_mesh.($bndshapes)
            bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
            bmesh.inspectable[] = false
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, plotdata["coords"]; color = plotdata["colors"], markersize = markersize, inspector_label = inspectorlabel, kwargs...)
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
- resolution ----- (800,600)
- gridposition --- (1,1)  # if an MSA is already plotted, (2,1:3) works well
- plottype ------- :covalent, :ballandstick, or :spacefilling
- atomcolors ----- elecolors, others in `getbiocolors`, or provide a dict for atoms/residues like: "N" => :blue
- markersize ----- 0.0
- markerscale ---- 1.0
- bondtype ------- :knowledgebased, :covalent, or :distance
- distance ------- 1.9  # distance cutoff for covalent bonds
- inspectorlabel - :default, or define your own function like: (self, i, p) -> "atom: ... coords: ..."
- kwargs... ------ keyword arguments passed to the atom `meshscatter`
"""
function plotstruc(struc::Observable;
                    resolution = (800,600),
                    gridposition = (1,1),
                    plottype = :covalent,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :knowledgebased,
                    distance = 1.9,
                    inspectorlabel = :default,
                    kwargs...
                    )
	fig = Figure()
    if !(typeof(struc)<:Observable)
        struc = Observable(struc)
    end
    plotstruc!(fig, struc; kwargs...)
end
