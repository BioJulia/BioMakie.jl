using Pkg
# Add this fork of the ProtoSyn package because it has a bugfix
Pkg.add(url="https://github.com/kool7d/ProtoSyn.jl")

using ProtoSyn
import BioMakie: plotstruc!, plotstruc, covalentradii, getbonds, atomradii, 
	atomradius, getinspectorlabel

"""
	distancebonds( atms, atmstates ) -> BitMatrix

Returns a matrix of all bonds in `atms`, where Mat[i,j] = 1 if atoms i and j are bonded. 

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- cutoff ----------- 1.9   # distance cutoff for bonds between heavy atoms
- hydrogencutoff --- 1.14  # distance cutoff for bonds with hydrogen atoms
- H ---------------- true  # include bonds with hydrogen atoms
- disulfides ------- false # include disulfide bonds
"""
function distancebonds(atms::Vector{T}, atmstate::Vector{S}; 
						cutoff = 1.9, 
						hydrogencutoff = 1.14, 
						H = true,
						disulfides = false) where {T<:ProtoSyn.Atom, S<:ProtoSyn.AtomState}
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix
	if atmstate[1].index == -1 && atmstate[2].index == -1 && atmstate[3].index == -1 && atmstate[4].index != -1
		atmstate = atmstate[4:end]
	end
	@assert length(atmstate) == numatoms

	for i in 1:numatoms
		for j in (i+1):numatoms
			if atms[i].name in ["N","CA","C","O"] && atms[j].name in ["N","CA","C","O"]
				if euclidean(atmstate[i].t, atmstate[j].t) < cutoff
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			end
			if bondmatrix[i,j] == 1
				continue
			end
			if atms[i].container == atms[j].container
				if H == true
					if atms[i].symbol == "H" || atms[j].symbol == "H"
						if euclidean(atmstate[i].t, atmstate[j].t) < hydrogencutoff
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					elseif !(atms[i].symbol == "H" || atms[j].symbol == "H")
						if euclidean(atmstate[i].t, atmstate[j].t) < cutoff
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					end
				else
					if !(atms[i].symbol == "H" || atms[j].symbol == "H")
						if euclidean(atmstate[i].t, atmstate[j].t) < cutoff
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].symbol == "S" && atms[k].symbol == "S"
					if euclidean(atmstate[i].t, atmstate[k].t) < 2.1
						bondmatrix[i,k] = 1
						bondmatrix[k,i] = 1
					end
				end
			end
		end
	end

	return bondmatrix
end

"""
	covalentbonds( atms, atmstates ) -> BitMatrix

Returns a matrix of all bonds in `atms`, where Mat[i,j] = 1 if atoms i and j are bonded. 

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- extradistance ---- 0.14  # fudge factor for better inclusion
- H ---------------- true  # include bonds with hydrogen atoms
- disulfides ------- false # include disulfide bonds
"""
function covalentbonds(atms::Vector{T}, atmstates::Vector{S}; 
						extradistance = 0.14, 
						H = true,
						disulfides = false) where {T<:ProtoSyn.Atom, S<:ProtoSyn.AtomState}
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix
	if atmstate[1].index == -1 && atmstate[2].index == -1 && atmstate[3].index == -1 && atmstate[4].index != -1
		atmstate = atmstate[4:end]
	end
	@assert length(atmstate) == numatoms

	for i in 1:numatoms
		for j in (i+1):numatoms
			### backbone bonds ###
			if atms[i].name in ["N","CA","C","O"] && atms[j].name in ["N","CA","C","O"]
				if euclidean(atmstates[i].t, atmstates[j].t) < (covalentradii[atms[i].symbol] + 
						covalentradii[atms[j].symbol] + extradistance)
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			end
			if bondmatrix[i,j] == 1
				continue
			end
			### residue bonds ###
			if atms[i].container == atms[j].container
				if H == true
					if euclidean(atmstates[i].t, atmstates[j].t) < (covalentradii[atms[i].symbol] + 
							covalentradii[atms[j].symbol] + extradistance)
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				else
					if !(atms[i].symbol == "H" || atms[j].symbol == "H")
						if euclidean(atmstates[i].t, atmstates[j].t) < (covalentradii[atms[i].symbol] + 
								covalentradii[atms[j].symbol] + extradistance)
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].symbol == "S" && atms[k].symbol == "S"
					if euclidean(atmstates[i].t, aatmstatestms[k].t) < 2.1
						bondmatrix[i,k] = 1
						bondmatrix[k,i] = 1
					end
				end
			end
		end
	end

	return bondmatrix
end

"""
	getbonds( atoms, atomstates ) -> BitMatrix

Returns a matrix of all bonds in `atoms::Vector{ProtoSyn.Atom}`, 
where Mat[i,j] = 1 if atoms i and j are bonded based on the 
atom states which contain coordinate information.
The default algorithm is acquiring bonds based on the 
`bonds` field of the `ProtoSyn.Atom` type.

### Keyword Arguments:
- algo ------------- :default 			# (:distance, :covalent) algorithm to find bonds
- H ---------------- true				# include bonds with hydrogen atoms
- cutoff ----------- 1.9				# distance cutoff for bonds between heavy atoms
- extradistance ---- 0.14				# fudge factor for better inclusion
- disulfides ------- false				# include disulfide bonds
"""
function getbonds(atms::Vector{T}, atmstate::Vector{S};
				algo = :default,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false) where {T<:ProtoSyn.Atom, S<:ProtoSyn.AtomState}
	#
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix


	# Do this later!
	# if algo == :knowledgebased
	# 	for i in 1:numatoms
	# 		resatoms = BioStructures.collectatoms(atms[i].residue) .|> defaultatom
	# 		numresatoms = size(resatoms,1)
	# 		if numresatoms < 2
	# 			continue
	# 		end
	# 		resatmkeys = [resatoms[i].name for i in 1:numresatoms]
	# 		nextresatms = (i+numresatoms)
	# 		if (i+numresatoms) > numatoms
	# 			nextresatms = numatoms
	# 		end
	# 		for j in (i+1):nextresatms
	# 			### backbone atoms ###
	# 			firstatomname = atms[i].name |> strip
	# 			secondatomname = atms[j].name |> strip
	# 			if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
	# 				if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
	# 					bondmatrix[i,j] = 1
	# 					bondmatrix[j,i] = 1
	# 				end
	# 			end
	# 			if bondmatrix[i,j] == 1
	# 				continue
	# 			end
	# 			### residue atoms ###
	# 			if atms[i].residue == atms[j].residue
	# 				atmres = atms[i].residue
	# 				heavybondresz = heavyresbonds[atmres.name] |> combinedims
	# 				heavylength = size(heavybondresz,2)
	# 				for k in 1:heavylength
	# 					if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
	# 							firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
	# 						bondmatrix[i,j] = 1
	# 						bondmatrix[j,i] = 1
	# 						break
	# 					end
	# 				end
	# 				### hydrogen atoms ###
	# 				if H == true
	# 					hbondresz = hresbonds[atmres.name] |> combinedims
	# 					if size(hbondresz,1) <= 1
	# 						continue
	# 					end
	# 					hlength = size(hbondresz,2)
	# 					for k in 1:hlength
	# 						if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
	# 							bondmatrix[i,j] = 1
	# 							bondmatrix[j,i] = 1
	# 							break
	# 						end
	# 					end
	# 				end
	# 			end
	# 		end
	# 		### disulfide bonds ###
	# 		if disulfides == true
	# 			for k in 1:numatoms
	# 				if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
	# 					if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
	# 						bondmatrix[i,k] = 1
	# 						bondmatrix[k,i] = 1
	# 					end
	# 				end
	# 			end
	# 		end
	# 	end
	# 	return bondmatrix
	
	if algo == :distance
		return distancebonds(atms, atmstate; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms, atmstate; extradistance = extradistance, H = H, disulfides = disulfides)
	# ProtoSyn.Atoms store bond information, so we can just use that
	elseif algo == :default
		for i in 1:length(atms)
			for ii in 1:length(atms[i].bonds)
				bondmatrix[atms[i].id, atms[i].bonds[ii].id] = true
				bondmatrix[atms[i].bonds[ii].id, atms[i].id] = true
			end
		end
		return bondmatrix
	else # just do the same as :covalent for now
		return covalentbonds(atms, atmstate; extradistance = extradistance, H = H, disulfides = disulfides)
	end
	return nothing
end
getbonds(pose::ProtoSyn.Pose) = getbonds(pose.atoms, pose.atmstate)

"""
    atomradii( atoms )

Collect atom radii based on element for plotting.

### Keyword Arguments:
- radiustype --- :ballandstick | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick, :spacefilling
"""
function atomradii(atoms::Vector{T}; radiustype = :ballandstick) where T<:ProtoSyn.Atom
	if radiustype == :covalent || radiustype == :cov
		return [covalentradii[x.symbol] for x in atoms]
	elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
		return [vanderwaalsradii[x.symbol] for x in atoms]
    elseif radiustype == :ballandstick || radiustype == :bas
		return [covalentradii[x.symbol] for x in atoms]
	else
        println("radiustype not recognized, using covalent radii")
		return [covalentradii[x.symbol] for x in atoms]
	end
end
function atomradii(atoms::Observable{T}; radiustype = :ballandstick) where T<:Vector{ProtoSyn.Atom}
    if radiustype == :covalent || radiustype == :cov
        radii = @lift [covalentradii[x.symbol] for x in $atoms]
        return radii
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        radii = @lift [vanderwaalsradii[x.symbol] for x in $atoms]
        return radii
    elseif radiustype == :ballandstick || radiustype == :bas
        radii = @lift [covalentradii[x.symbol] for x in $atoms]
        return radii
    else
        println("radiustype not recognized, using covalent radii")
        radii = @lift [covalentradii[x.symbol] for x in $atoms]
        return radii
    end
end

"""
    atomradius( atom )

Collect atom radius based on element for plotting.

### Keyword Arguments:
- radiustype --- :ballandstick | Options - :cov, :covalent, :vdw, :vanderwaals, :bas, :ballandstick, :spacefilling
"""
function atomradius(atom::T; radiustype = :ballandstick) where T<:ProtoSyn.Atom
    if radiustype == :covalent || radiustype == :cov
        return covalentradii[atom.symbol]
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        return vanderwaalsradii[atom.symbol]
    elseif radiustype == :ballandstick || radiustype == :bas
		return covalentradii[atom.symbol]
    else
        println("radiustype not recognized, using covalent radii")
        return covalentradii[atom.symbol]
    end
end
function atomradius(atom::Observable{T}) where T<:ProtoSyn.Atom
    if radiustype == :covalent || radiustype == :cov
        radii = @lift getindex(covalentradii, $atom.symbol)
        return radii
    elseif radiustype == :vanderwaals || radiustype == :vdw || radiustype == :spacefilling
        radii = @lift getindex(vanderwaalsradii, $atom.symbol)
        return radii
    elseif radiustype == :ballandstick || radiustype == :bas
        radii = @lift getindex(covalentradii, $atom.symbol)
        return radii
    else
        println("radiustype not recognized, using covalent radii")
        radii = @lift getindex(covalentradii, $atom.symbol)
        return radii
    end
end

"""
    getinspectorlabel( pose )
    getinspectorlabel( atoms, pose )

Get the inspector label function for plotting a 'StructuralElementOrList'.

This function uses 'MIToS.PDB.bestoccupancy' or 'defaultatom' to ensure only one position per atom.
"""
function getinspectorlabel(pose::ProtoSyn.Pose)
    atmselect = TrueSelection{ProtoSyn.Atom}()
    atms = atmselect(pose; gather = true)
    func = (self, i, p) -> "chain: $(atms[i].container.container.name)   " *
    "res: $(atms[i].container.name)   resid: $(atms[i].container.id)   index: $(i)\n" *
    "atom: $(atms[i].name)   element: $(atms[i].symbol)   " *
    "serial: $(atms[i].id)\ncoordinates: $(pose.state[atms[i]].t)"
    return func
end
function getinspectorlabel(atms::Vector{ProtoSyn.Atom}, pose::ProtoSyn.Pose)
    func = (self, i, p) -> "chain: $(atms[i].container.container.name)   " *
    "res: $(atms[i].container.name)   resid: $(atms[i].container.id)   index: $(i)\n" *
    "atom: $(atms[i].name)   element: $(atms[i].symbol)   " *
    "serial: $(atms[i].id)\ncoordinates: $(pose.state[atms[i]].t)"
    return func
end
function getinspectorlabel(atms::Observable{T}, pose::ProtoSyn.Pose) where {T<:Vector{ProtoSyn.Atom}}
    func = (self, i, p) -> "chain: $(atms[][i].container.container.name)   " *
    "res: $(atms[][i].container.name)   resid: $(atms[][i].container.id)   index: $(i)\n" *
    "atom: $(atms[][i].name)   element: $(atms[][i].symbol)   " *
    "serial: $(atms[][i].id)\ncoordinates: $(pose.state[atms[][i]].t)"
    return func
end
function getinspectorlabel(atms::T, states::S) where {T<:Vector{ProtoSyn.Atom},S<:Vector{AtomState{Float64}}}
    func = (self, i, p) -> "chain: $(atms[i].container.container.name)   " *
    "res: $(atms[i].container.name)   resid: $(atms[i].container.id)   index: $(i)\n" *
    "atom: $(atms[i].name)   element: $(atms[i].symbol)   " *
    "serial: $(atms[i].id)\ncoordinates: $(states[i].t)"
    return func
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
function atomcolors(atms::Vector{ProtoSyn.Atom}; colors = elecolors)
    colrs = [colors[x.symbol] for x in atms]
    return colrs
end
function atomcolors(atms::Observable{T}; colors = elecolors) where {T<:Vector{ProtoSyn.Atom}}
    colrs = @lift [colors[x.symbol] for x in $atms]
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
function rescolors(atms::Vector{ProtoSyn.Atom}; colors = maecolors)
    resnames = [atms[i].container.name for i in 1:length(atms)]
    colrs = [colors[resletterdict[resnames[j]]] for j in 1:length(resnames)]
    return colrs
end
function rescolors(atms::Observable{T}; colors = maecolors) where {T<:Vector{ProtoSyn.Atom}}
    resnames = @lift [$atms[i].container.name for i in 1:length($atms)]
    colrs = @lift [colors[resletterdict[$resnames[j]]] for j in 1:length($resnames)]
    return colrs
end
function rescolors(resz::Vector{ProtoSyn.Residue}; colors = maecolors)
    resnames = [resz[i].name for i in 1:length(resz)]
    colrs = [colors[resletterdict[resnames[j]]] for j in 1:length(resnames)]
    return colrs
end
function rescolors(resz::Observable{T}; colors = maecolors) where {T<:Vector{ProtoSyn.Residue}}
    resnames = @lift [$resz[i].name for i in 1:length($resz)]
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
function atomsizes(atms::Vector{ProtoSyn.Atom}; radiustype = :ballandstick)
    sizes = atomradii(atms; radiustype = radiustype)
    return sizes
end
function atomsizes(atms::Observable{T}; radiustype = :ballandstick) where {T<:Vector{ProtoSyn.Atom}}
    sizes = @lift atomradii($atms; radiustype = radiustype)
    return sizes
end

import BioMakie: plottingdata
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
function plottingdata(pose::Observable{T};
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false,
                        selection = ProtoSyn.ProteinSelection()) where {T<:ProtoSyn.Pose{Topology}}
    #
    if water == false
        selectwater = FieldSelection{ProtoSyn.Residue}("HOH", :name)
        selectatoms = (TrueSelection{ProtoSyn.Atom}() & selection & !selectwater)
        atms = @lift selectatoms($pose; gather = true)
    else
        selectatoms = (TrueSelection{ProtoSyn.Atom}() & selection)
        atms = @lift selectatoms($pose; gather = true)
    end
    atmselection = @lift (TrueSelection{ProtoSyn.Atom}() & selection)($pose)
    idxs = @lift [i for i in 1:length($atmselection.content) if $atmselection.content[i] .== 1]
    atmstates = @lift $pose.state.items[$idxs.+3]
	
    atmcords = @lift [$atmstates[i].t for i in 1:length($idxs)] |> combinedims |> transpose |> collect
    colrs = []
    colrs = @lift to_color.([colors[$atms[i].symbol] for i in 1:length($atms)])
    sizes = @lift atomradii($atms; radiustype = radiustype)
    bonds = @lift getbonds($atms, $atmstates)

	resids = @lift [$atms[i].container.id for i in 1:length($atms)]

	selected = @lift [false for i in 1:length($atms)]

    return OrderedDict(:atoms => atms, 
                        :coords => atmcords, 
                        :colors => colrs,
                        :sizes => sizes,
                        :bonds => bonds,
                        :states => atmstates,
						:resids => resids,
						:selected => selected)
end
function plottingdata(pose::ProtoSyn.Pose;
                        colors = elecolors,
                        radiustype = :ballandstick,
                        water = false,
                        selection = ProtoSyn.ProteinSelection())
    #
	return plottingdata(Observable(pose); colors = colors, 
						radiustype = radiustype, water = water, selection = selection)
end

"""
    plotstruc!( fig, structure )
    plotstruc!( gridposition, structure )
    plotstruc!( fig, plotdata )
    plotstruc!( gridposition, plotdata )

Plot a protein structure(pose) into a Figure. 

# Examples
```julia
fig = Figure()

using ProtoSyn

pose = ProtoSyn.Peptides.load("2vb1.pdb"; bonds_by_distance=true) |> Observable
strucplot = plotstruc!(fig, pose)
```

### Keyword Arguments:
- resolution ----- (600,600)
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
function plotstruc!(fig::Figure, pose::Observable{ProtoSyn.Pose{Topology}};
                    resolution = (600,600),
                    gridposition = (1,1),
                    plottype = :ballandstick,
                    atomcolors = elecolors,
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :default,
                    distance = 1.9,
                    inspectorlabel = :default,
                    water = false,
                    kwargs...
                    )
	#
    plotdata = plottingdata(pose; colors = atomcolors, radiustype = plottype, water = water)
    atms = plotdata[:atoms]
    cords = plotdata[:coords]
    colrs = plotdata[:colors]
    sizes = plotdata[:sizes]
    bnds = plotdata[:bonds]
	resz = plotdata[:resids]
    atmstates = plotdata[:states]
	selected = plotdata[:selected]

    selectioncolor = RGBA(0.5647059f0,0.93333334f0,0.5647059f0,0.7f0)
    if atomcolors == aquacolors
        selectioncolor = RGBA(1.0f0,0.7529412f0,0.79607844f0,0.7f0)
    end

	selectedcoords = Observable(Matrix{Float64}(undef,0,3))
    on(selected; update = true) do sel
        if sum(sel) == 0
            selectedcoords[] = Matrix{Float64}(undef,0,3)
        else
            try
                selectedcoords[] = [cords[][i,:] for i in 1:length(sel) if sel[i] == true] |> combinedims |> transpose |> collect
            catch
                selectedcoords[] = [cords[][i,:] for i in 1:length(sel) if sel[i] == true] |> transpose |> collect
            end
        end
    end 
    
    sizs = Observable(Vector{Float32}(undef,length(selected[])) .= 0)
    on(selected; update = true) do sel
        if sum(sel) == 0
            sizs[] = Vector{Float32}(undef,0) .= 0
        else
            sizs[] = [sizes[][i] for i in 1:length(selected[]) if selected[][i] == true] .+ 0.3
        end
    end

    pxwidths = fig.scene.px_area[].widths
    needresize = false
    # the figure needs to be resized if there's a preexisting MSA plot (with default resolution)
    if pxwidths == [1000,350]
        needresize = true
    end
    if inspectorlabel == :default
        inspectorlabel = @lift getinspectorlabel($atms, $atmstates)        
    end
    if plottype == :spacefilling || plottype == :vanderwaals || plottype == :vdw
        markersize = @lift $sizes .* markerscale
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
		slc = meshscatter!(lscene, selectedcoords; 
                            color = selectioncolor, markersize = sizs)
        slc.attributes.inspectable[] = false
    elseif plottype == :ballandstick || plottype == :bas
        if markersize == 0.0
            markersize = @lift $sizes .* markerscale .* 0.7
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        if bnds == nothing
            bnds = @lift getbonds($atms, $atmstates; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
		slc = meshscatter!(lscene, selectedcoords; 
                            color = selectioncolor, markersize = sizs)
        slc.attributes.inspectable[] = false
    elseif plottype == :covalent || plottype == :cov
        markersize = @lift $sizes .* markerscale
		if bnds == nothing
			bnds = @lift getbonds($atms, $atmstates; algo = bondtype, distance = distance)
		end
		bndshapes = @lift bondshapes($cords, $bnds)
		bndmeshes = @lift normal_mesh.($bndshapes)
		bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
		bmesh.inspectable[] = false
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
		slc = meshscatter!(lscene, selectedcoords; 
                            color = selectioncolor, markersize = sizs)
        slc.attributes.inspectable[] = false
    else
        ArgumentError("bad plottype kwarg")
    end

	# mouse selection
    mouseevents = addmouseevents!(fig.content[1].scene, fig.content[1].scene.plots[1]; priority = 1)
    onmouseleftclick(mouseevents) do event
        picked = mouse_selection(fig.content[1].scene)
        selectedatm = [picked...][2]
        selectres = Vector{Bool}(undef,length(selected[])) .= false
        atmidxs = [i for i in 1:length(resz[]) if resz[][i] == resz[][selectedatm]]
        selectres[atmidxs] .= true
        selected[] = selectres
    end

    # the window has to be reopened to resize at the moment
    if needresize == true
        fig.scene.px_area[] = HyperRectangle{2, Int64}([0, 0], [pxwidths[1], pxwidths[2]+resolution[2]])
        Makie.update_state_before_display!(fig)
    end
    DataInspector(lscene; indicator_linewidth = 0)
    fig
end

"""
    _plotstruc!( fig, plotdata )
    _plotstruc!( gridposition, plotdata )

Plot Pose data into a Figure. 

# Examples
```julia
using ProtoSyn

pose = ProtoSyn.Peptides.load("2vb1.pdb"; bonds_by_distance=true)
pdata = plottingdata(pose)

fig = Figure()
_plotstruc!(fig, pdata)
```

### Keyword Arguments:
- resolution ----- (600,600)
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
function _plotstruc!(fig::Figure, plotdata::AbstractDict{Symbol,T};
                    resolution = (600,600),
                    gridposition = (1,1),
                    plottype = :ballandstick,
                    atomcolors = elecolors, # has no effect since plotdata already has colors
                    markersize = 0.0,
                    markerscale = 1.0,
                    bondtype = :knowledgebased,
                    distance = 1.9,
                    inspectorlabel = :default,
                    water = false,
                    kwargs...
                    ) where {T<:Observable}
	#
    atms = plotdata[:atoms]
    cords = plotdata[:coords]
    colrs = plotdata[:colors]
    sizes = plotdata[:sizes]
    bnds = plotdata[:bonds]
	resz = plotdata[:resids]
    atmstates = plotdata[:states]
	selected = plotdata[:selected]

    selectioncolor = RGBA(0.5647059f0,0.93333334f0,0.5647059f0,0.7f0)
    if atomcolors == aquacolors
        selectioncolor = RGBA(1.0f0,0.7529412f0,0.79607844f0,0.7f0)
    end

	selectedcoords = Observable(Matrix{Float64}(undef,0,3))
    on(selected; update = true) do sel
        if sum(sel) == 0
            selectedcoords[] = Matrix{Float64}(undef,0,3)
        else
            try
                selectedcoords[] = [cords[][i,:] for i in 1:length(sel) if sel[i] == true] |> combinedims |> transpose |> collect
            catch
                selectedcoords[] = [cords[][i,:] for i in 1:length(sel) if sel[i] == true] |> transpose |> collect
            end
        end
    end 
    
    sizs = Observable(Vector{Float32}(undef,length(selected[])) .= 0)
    on(selected; update = true) do sel
        if sum(sel) == 0
            sizs[] = Vector{Float32}(undef,0) .= 0
        else
            sizs[] = [sizes[][i] for i in 1:length(selected[]) if selected[][i] == true] .+ 0.3
        end
    end

    pxwidths = fig.scene.px_area[].widths
    needresize = false
    # the figure needs to be resized if there's a preexisting MSA plot (with default resolution)
    if pxwidths == [1000,350]
        needresize = true
    end
    if inspectorlabel == :default
        inspectorlabel = @lift getinspectorlabel($atms, $atmstates)        
    end
    if plottype == :spacefilling || plottype == :vanderwaals || plottype == :vdw
        markersize = @lift $sizes .* markerscale
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
		slc = meshscatter!(lscene, selectedcoords; 
                            color = selectioncolor, markersize = sizs)
        slc.attributes.inspectable[] = false
    elseif plottype == :ballandstick || plottype == :bas
        if markersize == 0.0
            markersize = @lift $sizes .* markerscale .* 0.7
        end
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
        if bnds == nothing
            bnds = @lift getbonds($atms, $atmstates; algo = bondtype, distance = distance)
        end
        bndshapes = @lift bondshapes($cords, $bnds)
        bndmeshes = @lift normal_mesh.($bndshapes)
        bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
        bmesh.inspectable[] = false
		slc = meshscatter!(lscene, selectedcoords; 
                            color = selectioncolor, markersize = sizs)
        slc.attributes.inspectable[] = false
    elseif plottype == :covalent || plottype == :cov
        markersize = @lift $sizes .* markerscale
		if bnds == nothing
			bnds = @lift getbonds($atms, $atmstates; algo = bondtype, distance = distance)
		end
		bndshapes = @lift bondshapes($cords, $bnds)
		bndmeshes = @lift normal_mesh.($bndshapes)
		bmesh = mesh!(lscene, bndmeshes, color = RGBA(0.5,0.5,0.5,0.8))
		bmesh.inspectable[] = false
        lscene = LScene(fig[gridposition...]; height = resolution[2], width = resolution[1], show_axis = false)
        ms = meshscatter!(lscene, cords; color = colrs, markersize = markersize, inspector_label = inspectorlabel, kwargs...)
		slc = meshscatter!(lscene, selectedcoords; 
                            color = selectioncolor, markersize = sizs)
        slc.attributes.inspectable[] = false
    else
        ArgumentError("bad plottype kwarg")
    end

	# mouse selection
    mouseevents = addmouseevents!(fig.content[1].scene, fig.content[1].scene.plots[1]; priority = 1)
    onmouseleftclick(mouseevents) do event
        picked = mouse_selection(fig.content[1].scene)
        selectedatm = [picked...][2]
        selectres = Vector{Bool}(undef,length(selected[])) .= false
        atmidxs = [i for i in 1:length(resz[]) if resz[][i] == resz[][selectedatm]]
        selectres[atmidxs] .= true
        selected[] = selectres
    end

    # the window has to be reopened to resize at the moment
    if needresize == true
        fig.scene.px_area[] = HyperRectangle{2, Int64}([0, 0], [pxwidths[1], pxwidths[2]+resolution[2]])
        Makie.update_state_before_display!(fig)
    end
    DataInspector(lscene; indicator_linewidth = 0)
    fig
end
function plotstruc!(fig::Figure, struc::T; atomcolors = elecolors, plottype = :ballandstick, 
					water = false, kwargs...) where {T<:ProtoSyn.Pose{Topology}}
	plotdata = plottingdata(struc; colors = atomcolors, radiustype = plottype, water = water)
	plotstruc!(fig, plotdata; atomcolors = atomcolors, plottype = plottype, water = water, kwargs...)
end
function plotstruc!(figposition::GridPosition, pose::T; atomcolors = elecolors, plottype = :ballandstick, 
					water = false, kwargs...) where {T<:Observable{ProtoSyn.Pose{Topology}}}
	plotdata = plottingdata(struc; colors = atomcolors, radiustype = plottype, water = water)
	plotstruc!(figposition, plotdata; atomcolors = atomcolors, plottype = plottype, water = water, kwargs...)
end
