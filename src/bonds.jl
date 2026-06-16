export distancebonds,
	   covalentbonds,
	   sidechainbonds,
	   backbonebonds,
	   getbonds,
	   bondmatrix,
	   bondshape,
	   bondshapes

# Atom names used to detect inter-residue backbone connections via distance, since
# heavyresbonds/hresbonds only encode intra-residue bonds. Covers the protein peptide
# bond (C-N) and the DNA/RNA phosphodiester bond (O3'-P).
const backboneconnectoratoms = ["N","CA","C","O","P","O3'"]

# Intern atom names shared across the ~50k residue types in heavyresbonds/hresbonds so identical names share one String object, cutting both dictionaries' footprint.
let pool = Dict{String,String}()
	intern(s) = get!(pool, s, s)
	for d in (heavyresbonds, hresbonds), k in keys(d)
		d[k] = [(intern(a), intern(b)) for (a,b) in d[k]]
	end
end

"""
	hasknowledgebasedbond( bondlist, atom1, atom2 ) -> Bool

Returns true if (atom1, atom2) appears (in either order) in a knowledge-based bond list
from heavyresbonds/hresbonds. Empty entries (e.g. ions like ZN, SCN) simply return false.
"""
function hasknowledgebasedbond(bondlist::AbstractVector{<:Tuple{<:AbstractString,<:AbstractString}},
							   atom1::AbstractString, atom2::AbstractString)
	for (x,y) in bondlist
		((atom1 == x && atom2 == y) || (atom1 == y && atom2 == x)) && return true
	end
	return false
end

"""
	distancebonds( atms ) -> Vector{Tuple{Int,Int}}

Returns the bonds in `atms` as a vector of `(i, j)` index pairs, one per bonded atom pair.

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- cutoff ----------- 1.9   # distance cutoff for bonds between heavy atoms
- hydrogencutoff --- 1.14  # distance cutoff for bonds with hydrogen atoms
- H ---------------- true  # include bonds with hydrogen atoms
- disulfides ------- false # include disulfide bonds
"""
function distancebonds(atms::AbstractVector{T};
						cutoff = 1.9,
						hydrogencutoff = 1.14,
						H = true,
						disulfides = false) where {T<:BioStructures.AbstractAtom}
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	for i in 1:numatoms
		resatoms = BioStructures.collectatoms(atms[i].residue) .|> defaultatom
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			### backbone bonds ###
			if strip(atms[i].name) in backboneconnectoratoms && strip(atms[j].name) in backboneconnectoratoms
				if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
					push!(bonds, (min(i,j),max(i,j)))
				end
			end
			### residue bonds ###
			if atms[i].residue == atms[j].residue
				if H == true
					if !(strip(atms[i].element) == "H" || strip(atms[j].element) == "H")
						if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
							push!(bonds, (min(i,j),max(i,j)))
						end
					else
						if euclidean(coords(atms[i]), coords(atms[j])) < hydrogencutoff
							push!(bonds, (min(i,j),max(i,j)))
						end
					end
				else
					if !(strip(atms[i].element) == "H" || strip(atms[j].element) == "H")
						if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
							push!(bonds, (min(i,j),max(i,j)))
						end
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
					if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
						push!(bonds, (min(i,k),max(i,k)))
					end
				end
			end
		end
	end

	return unique!(bonds)
end
function distancebonds(resz::AbstractVector{T};
						cutoff = 1.9,
						hydrogencutoff = 1.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBResidue}
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	resindices = [[i for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	resnames = [[resz[i].id.name for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	for i in 1:numatoms
		resatoms = bestoccupancy(resz[resindices[i]].atoms)
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			if atms[i].atom in backboneconnectoratoms && atms[j].atom in backboneconnectoratoms
				if euclidean(atms[i].coordinates, atms[j].coordinates) < cutoff
					push!(bonds, (min(i,j),max(i,j)))
				end
			end
			if resindices[i] == resindices[j]
				if H == true
					if atms[i].element == "H" || atms[j].element == "H"
						if euclidean(atms[i].coordinates,atms[j].coordinates) < hydrogencutoff
							push!(bonds, (min(i,j),max(i,j)))
						end
					elseif !(atms[i].element == "H" || atms[j].element == "H")
						if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
							push!(bonds, (min(i,j),max(i,j)))
						end
					end
				else
					if !(atms[i].element == "H" || atms[j].element == "H")
						if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
							push!(bonds, (min(i,j),max(i,j)))
						end
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
						push!(bonds, (min(i,k),max(i,k)))
					end
				end
			end
		end
	end

	return unique!(bonds)
end
function distancebonds(atms::AbstractVector{T};
						cutoff = 1.9,
						hydrogencutoff = 1.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBAtom}
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	for i in 1:numatoms
		for j in (i+1):numatoms
			if H == true
				if atms[i].element == "H" || atms[j].element == "H"
					if euclidean(atms[i].coordinates,atms[j].coordinates) < hydrogencutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				elseif !(atms[i].element == "H" || atms[j].element == "H")
					if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			else
				if !(atms[i].element == "H" || atms[j].element == "H")
					if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
						push!(bonds, (min(i,k),max(i,k)))
					end
				end
			end
		end
	end

	return unique!(bonds)
end

"""
	covalentbonds( atms ) -> Vector{Tuple{Int,Int}}

Returns a matrix of all bonds in `atms`, where Mat[i,j] = 1 if atoms i and j are bonded.

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- extradistance ---- 0.14  # fudge factor for better inclusion
- H ---------------- true  # include bonds with hydrogen atoms
- disulfides ------- false # include disulfide bonds
"""
function covalentbonds(atms::AbstractVector{T};
						extradistance = 0.14,
						H = true,
						disulfides = false) where {T<:BioStructures.AbstractAtom}
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	for i in 1:numatoms
		resatoms = BioStructures.collectatoms(atms[i].residue) .|> defaultatom
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			### backbone bonds ###
			if strip(atms[i].name) in backboneconnectoratoms && strip(atms[j].name) in backboneconnectoratoms
				if euclidean(coords(atms[i]), coords(atms[j])) < (get(covalentradii, BioStructures.element(atms[i]), 0.77f0) +
						get(covalentradii, BioStructures.element(atms[j]), 0.77f0) + extradistance)
					push!(bonds, (min(i,j),max(i,j)))
				end
			end
			### residue bonds ###
			if atms[i].residue == atms[j].residue
				if H == true
					if euclidean(coords(atms[i]), coords(atms[j])) < (get(covalentradii, strip(atms[i].element), 0.77f0) +
							get(covalentradii, strip(atms[j].element), 0.77f0) + extradistance)
						push!(bonds, (min(i,j),max(i,j)))
					end
				else
					if !(strip(atms[i].element) == "H" || strip(atms[j].element) == "H")
						if euclidean(coords(atms[i]), coords(atms[j])) < (get(covalentradii, strip(atms[i].element), 0.77f0) +
								get(covalentradii, strip(atms[j].element), 0.77f0) + extradistance)
							push!(bonds, (min(i,j),max(i,j)))
						end
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
					if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
						push!(bonds, (min(i,k),max(i,k)))
					end
				end
			end
		end
	end

	return unique!(bonds)
end
function covalentbonds(resz::AbstractVector{T};
						extradistance = 0.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBResidue}
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	resindices = [[i for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	resnames = [[resz[i].id.name for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	for i in 1:numatoms
		resatoms = bestoccupancy(resz[resindices[i]].atoms)
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			### backbone bonds ###
			if atms[i].atom in backboneconnectoratoms && atms[j].atom in backboneconnectoratoms
				if euclidean(atms[i].coordinates, atms[j].coordinates) < (get(covalentradii, atms[i].element, 0.77f0) +
						get(covalentradii, atms[j].element, 0.77f0) + extradistance)
					push!(bonds, (min(i,j),max(i,j)))
				end
			end
			### residue bonds ###
			if resindices[i] == resindices[j]
				if H == true
					if euclidean(atms[i].coordinates,atms[j].coordinates) < (get(covalentradii, atms[i].element, 0.77f0) +
							get(covalentradii, atms[j].element, 0.77f0) + extradistance)
						push!(bonds, (min(i,j),max(i,j)))
					end
				else
					if !(atms[i].element == "H" || atms[j].element == "H")
						if euclidean(atms[i].coordinates,atms[j].coordinates) < (get(covalentradii, atms[i].element, 0.77f0) +
								get(covalentradii, atms[j].element, 0.77f0) + extradistance)
							push!(bonds, (min(i,j),max(i,j)))
						end
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
						push!(bonds, (min(i,k),max(i,k)))
					end
				end
			end
		end
	end

	return unique!(bonds)
end
function covalentbonds(atms::AbstractVector{T};
						extradistance = 0.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBAtom}
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	for i in 1:numatoms
		for j in (i+1):numatoms
			if H == true
				if euclidean(atms[i].coordinates,atms[j].coordinates) < (get(covalentradii, atms[i].element, 0.77f0) +
						get(covalentradii, atms[j].element, 0.77f0) + extradistance)
					push!(bonds, (min(i,j),max(i,j)))
				end
			else
				if !(atms[i].element == "H" || atms[j].element == "H")
					if euclidean(atms[i].coordinates,atms[j].coordinates) < (get(covalentradii, atms[i].element, 0.77f0) +
							get(covalentradii, atms[j].element, 0.77f0) + extradistance)
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
						push!(bonds, (min(i,k),max(i,k)))
					end
				end
			end
		end
	end

	return unique!(bonds)
end

"""
	sidechainbonds( res::BioStructures.AbstractResidue, selectors... ) -> Vector{Tuple{Int,Int}}

Returns a matrix of sidechain bonds in `res`, where Mat[i,j] = 1 if atoms i and j are bonded.

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- algo ------------- :knowledgebased 	# (:distance, :covalent) algorithm to find bonds
- H ---------------- true				# include bonds with hydrogen atoms
- cutoff ----------- 1.9				# distance cutoff for bonds between heavy atoms
- extradistance ---- 0.14				# fudge factor for better inclusion
"""
function sidechainbonds(res::BioStructures.AbstractResidue, selectors...;
						algo = :knowledgebased,
						H = true,
						cutoff = 1.9,
						extradistance = 0.14)
	resatomdict = res.atoms
	atms = BioStructures.collectatoms(res, selectors...) .|> defaultatom
	numatoms = size(atms, 1)
	bonds = Tuple{Int,Int}[]

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = BioStructures.collectatoms(atms[i].residue, selectors...) .|> defaultatom
			numresatoms = size(resatoms,1)
			nextresatms = (i+numresatoms)
			if (i+numresatoms) > numatoms
				nextresatms = numatoms
			end
			for j in (i+1):nextresatms
				### backbone atoms ###
				firstatomname = atms[i].name |> strip
				secondatomname = atms[j].name |> strip
				if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						continue
					end
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					if hasknowledgebasedbond(get(heavyresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
					### hydrogen atoms ###
					if H == true && hasknowledgebasedbond(get(hresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
		end
		return unique!(bonds)
	elseif algo == :distance
		return distancebonds(resatoms; cutoff = cutoff, H = H)
	elseif algo == :covalent
		return covalentbonds(resatoms; extradistance = extradistance, H = H)
	else # just do the same as :covalent for now
		return covalentbonds(resatoms; extradistance = extradistance, H = H)
	end
end

"""
	backbonebonds( chn::BioStructures.Chain ) -> Vector{Tuple{Int,Int}}

Returns a matrix of backbone bonds in `chn`, where Mat[i,j] = 1 if atoms i and j are bonded.

### Keyword Arguments:
- cutoff ----------- 1.6		# distance cutoff for bonds
"""
function backbonebonds(chn::BioStructures.Chain; cutoff = 1.6)
	bbatoms = BioStructures.collectatoms(chn, backboneselector) .|> defaultatom
	bonds = Tuple{Int,Int}[]

	for i in 1:size(bbatoms,1)
		for j in (i+1):size(bbatoms,1)
			firstatomname = strip(bbatoms[i].name)
			secondatomname = strip(bbatoms[j].name)
			if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
				if euclidean(coordarray(bbatoms[i]) |> transpose |> collect, coordarray(bbatoms[j]) |> transpose |> collect) < cutoff
					push!(bonds, (min(i,j),max(i,j)))
				end
			end
		end
	end

	return unique!(bonds)
end

"""
	getbonds( chn::BioStructures.Chain, selectors... ) -> Vector{Tuple{Int,Int}}
	getbonds( modl::BioStructures.Model, selectors... ) -> Vector{Tuple{Int,Int}}
	getbonds( struc::BioStructures.MolecularStructure, selectors... ) -> Vector{Tuple{Int,Int}}

Returns a matrix of all bonds in `chn`, where Mat[i,j] = 1 if atoms i and j are bonded.

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- algo ------------- :knowledgebased 	# (:distance, :covalent) algorithm to find bonds
- H ---------------- true				# include bonds with hydrogen atoms
- cutoff ----------- 1.9				# distance cutoff for bonds between heavy atoms
- extradistance ---- 0.14				# fudge factor for better inclusion
- disulfides ------- false				# include disulfide bonds
"""
function getbonds(chn::BioStructures.Chain, selectors...;
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false)
	atms = BioStructures.collectatoms(chn, selectors...) .|> defaultatom
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = BioStructures.collectatoms(atms[i].residue, selectors...) .|> defaultatom
			numresatoms = size(resatoms,1)
			if numresatoms < 2
				continue
			end
			resatmkeys = [resatoms[i].name for i in 1:numresatoms]
			nextresatms = (i+numresatoms)
			if (i+numresatoms) > numatoms
				nextresatms = numatoms
			end
			for j in (i+1):nextresatms
				### backbone atoms ###
				firstatomname = atms[i].name |> strip
				secondatomname = atms[j].name |> strip
				if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					if hasknowledgebasedbond(get(heavyresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
					### hydrogen atoms ###
					if H == true && hasknowledgebasedbond(get(hresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
			### disulfide bonds ###
			if disulfides == true
				for k in 1:numatoms
					if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
						if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
							push!(bonds, (min(i,k),max(i,k)))
						end
					end
				end
			end
		end
		return unique!(bonds)
	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end
function getbonds(modl::BioStructures.Model, selectors...;
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false)
	atms = BioStructures.collectatoms(modl, selectors...) .|> defaultatom
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = BioStructures.collectatoms(atms[i].residue, selectors...) .|> defaultatom
			numresatoms = size(resatoms,1)
			if numresatoms < 2
				continue
			end
			resatmkeys = [resatoms[i].name for i in 1:numresatoms]
			nextresatms = (i+numresatoms)
			if (i+numresatoms) > numatoms
				nextresatms = numatoms
			end
			for j in (i+1):nextresatms
				### backbone atoms ###
				firstatomname = atms[i].name |> strip
				secondatomname = atms[j].name |> strip
				if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					if hasknowledgebasedbond(get(heavyresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
					### hydrogen atoms ###
					if H == true && hasknowledgebasedbond(get(hresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
			### disulfide bonds ###
			if disulfides == true
				for k in 1:numatoms
					if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
						if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
							push!(bonds, (min(i,k),max(i,k)))
						end
					end
				end
			end
		end
		return unique!(bonds)
	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end
function getbonds(struc::BioStructures.MolecularStructure, selectors...;
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false)
	atms = BioStructures.collectatoms(struc, selectors...) .|> defaultatom
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = BioStructures.collectatoms(atms[i].residue, selectors...) .|> defaultatom
			numresatoms = size(resatoms,1)
			if numresatoms < 2
				continue
			end
			resatmkeys = [resatoms[i].name for i in 1:numresatoms]
			nextresatms = (i+numresatoms)
			if (i+numresatoms) > numatoms
				nextresatms = numatoms
			end
			for j in (i+1):nextresatms
				### backbone atoms ###
				firstatomname = atms[i].name |> strip
				secondatomname = atms[j].name |> strip
				if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					if hasknowledgebasedbond(get(heavyresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
					### hydrogen atoms ###
					if H == true && hasknowledgebasedbond(get(hresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
			### disulfide bonds ###
			if disulfides == true
				for k in 1:numatoms
					if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
						if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
							push!(bonds, (min(i,k),max(i,k)))
						end
					end
				end
			end
		end
		return unique!(bonds)
	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end

"""
	getbonds( residues ) -> Vector{Tuple{Int,Int}}

Returns a matrix of all bonds in `residues::Vector{MIToS.PDB.PDBResidue}`,
where Mat[i,j] = 1 if atoms i and j are bonded.

### Keyword Arguments:
- algo ------------- :knowledgebased 	# (:distance, :covalent) algorithm to find bonds
- H ---------------- true				# include bonds with hydrogen atoms
- cutoff ----------- 1.9				# distance cutoff for bonds between heavy atoms
- extradistance ---- 0.14				# fudge factor for better inclusion
- disulfides ------- false				# include disulfide bonds
"""
function getbonds(resz::Vector{MIToS.PDB.PDBResidue};
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false)

	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	resindices = [[i for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	resnames = [[resz[i].id.name for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]
	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = bestoccupancy(resz[resindices[i]].atoms)
			numresatoms = size(resatoms,1)
			if numresatoms < 2
				continue
			end
			resatmkeys = [resatoms[i].atom for i in 1:numresatoms]
			nextresatms = (i+numresatoms)
			if (i+numresatoms) > numatoms
				nextresatms = numatoms
			end
			for j in (i+1):nextresatms
				### backbone atoms ###
				firstatomname = atms[i].atom
				secondatomname = atms[j].atom
				if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
					if euclidean(atms[i].coordinates |> collect, atms[j].coordinates |> collect) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
				### residue atoms ###
				if resindices[i] == resindices[j] && hasknowledgebasedbond(get(heavyresbonds, resnames[i], Tuple{String,String}[]), firstatomname, secondatomname)
					push!(bonds, (min(i,j),max(i,j)))
				end
				### hydrogen atoms ###
				if H == true && hasknowledgebasedbond(get(hresbonds, resnames[i], Tuple{String,String}[]), firstatomname, secondatomname)
					push!(bonds, (min(i,j),max(i,j)))
				end
			end
			### disulfide bonds ###
			if disulfides == true
				for k in 1:numatoms
					if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
						if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
							push!(bonds, (min(i,k),max(i,k)))
						end
					end
				end
			end
		end
		return unique!(bonds)
	elseif algo == :distance
		return distancebonds(resz; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(resz; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(resz; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end
function getbonds(atms::Vector{MIToS.PDB.PDBAtom};
				algo = :covalent,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false)

	numatoms = size(atms,1)
	bonds = Tuple{Int,Int}[]
	warn("Using a vector of PDBAtoms is not recommended, use a vector of PDBResidues instead")

	if algo == :knowledgebased
		warn("Knowledge-based algorithm not implemented for Vector{MIToS.PDB.PDBAtom} yet, using :covalent instead")
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end
function getbonds(resz::AbstractVector{T};
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false) where {T<:BioStructures.AbstractResidue}

	atms = BioStructures.collectatoms(resz) .|> defaultatom
	numatoms = size(atms, 1)
	bonds = Tuple{Int,Int}[]

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = BioStructures.collectatoms(atms[i].residue) .|> defaultatom
			numresatoms = size(resatoms,1)
			if numresatoms < 2
				continue
			end
			resatmkeys = [resatoms[i].name for i in 1:numresatoms]
			nextresatms = (i+numresatoms)
			if (i+numresatoms) > numatoms
				nextresatms = numatoms
			end
			for j in (i+1):nextresatms
				### backbone atoms ###
				firstatomname = atms[i].name |> strip
				secondatomname = atms[j].name |> strip
				if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					if hasknowledgebasedbond(get(heavyresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
					### hydrogen atoms ###
					if H == true && hasknowledgebasedbond(get(hresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
			### disulfide bonds ###
			if disulfides == true
				for k in 1:numatoms
					if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
						if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
							push!(bonds, (min(i,k),max(i,k)))
						end
					end
				end
			end
		end
		return unique!(bonds)
	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end
function getbonds(atms::AbstractVector{T};
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false) where {T<:BioStructures.AbstractAtom}

	atms = atms .|> defaultatom
	numatoms = size(atms, 1)
	bonds = Tuple{Int,Int}[]

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = BioStructures.collectatoms(atms[i].residue) .|> defaultatom
			numresatoms = size(resatoms,1)
			if numresatoms < 2
				continue
			end
			resatmkeys = [resatoms[i].name for i in 1:numresatoms]
			nextresatms = (i+numresatoms)
			if (i+numresatoms) > numatoms
				nextresatms = numatoms
			end
			for j in (i+1):nextresatms
				### backbone atoms ###
				firstatomname = atms[i].name |> strip
				secondatomname = atms[j].name |> strip
				if firstatomname in backboneconnectoratoms && secondatomname in backboneconnectoratoms
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					if hasknowledgebasedbond(get(heavyresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
					### hydrogen atoms ###
					if H == true && hasknowledgebasedbond(get(hresbonds, atmres.name, Tuple{String,String}[]), firstatomname, secondatomname)
						push!(bonds, (min(i,j),max(i,j)))
					end
				end
			end
			### disulfide bonds ###
			if disulfides == true
				for k in 1:numatoms
					if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
						if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
							push!(bonds, (min(i,k),max(i,k)))
						end
					end
				end
			end
		end
		return unique!(bonds)
	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end

"""
	getbonds( coords ) -> Vector{Tuple{Int,Int}}

Returns a matrix of all bonds using a N x 3 coordinates matrix.
Uses a plain cutoff distance with algo option :distance. This is
not recommended as it can lead to incorrect results since different
atoms have different bond lengths and radii.

### Keyword Arguments:
- algo ------------- :distance 			# algorithm to find bonds
- H ---------------- true				# include bonds with hydrogen atoms
- cutoff ----------- 1.9				# distance cutoff for bonds between heavy atoms
- extradistance ---- 0.14				# fudge factor for better inclusion
- disulfides ------- false				# include disulfide bonds
"""
function getbonds(cords::AbstractArray{T};
				algo = :distance,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false) where {T<:AbstractFloat}
	#
	@assert size(cords,2) == 3 "coords must be an N x 3 matrix"
	numatoms = size(cords,1)
	bonds = Tuple{Int,Int}[]

	return distancebonds(cords; cutoff = cutoff, H = H, disulfides = disulfides)
end

"""
	bondshape( twoatoms )
	bondshape( twopoints )

Returns a (mesh) cylinder between two atoms or atomic coordinates.

### Keyword Arguments:
- bondwidth ------------- 0.2
"""
function bondshape(twoatoms::Tuple{T}; bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
    @assert length(twoatoms) == 2
	atm1 = defaultatom(twoatoms[1])
	atm2 = defaultatom(twoatoms[2])
	pnt1 = GeometryBasics.Point3f(atm1.coords)
    pnt2 = GeometryBasics.Point3f(atm2.coords)
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end
function bondshape(twoatoms::AbstractVector{T}; bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
    @assert length(twoatoms) == 2
	atm1 = defaultatom(twoatoms[1])
	atm2 = defaultatom(twoatoms[2])
	pnt1 = GeometryBasics.Point3f(atm1.coords)
    pnt2 = GeometryBasics.Point3f(atm2.coords)
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end
function bondshape(twopnts::AbstractVector{T}; bondwidth = 0.2) where {T<:GeometryBasics.AbstractPoint}
    @assert length(twopnts) == 2
	pnt1 = GeometryBasics.Point3f(twopnts[1])
    pnt2 = GeometryBasics.Point3f(twopnts[2])
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end
function bondshape(twopnts::AbstractMatrix{T}; bondwidth = 0.2) where {T<:AbstractFloat}
    if size(twopnts,1) == 3 && size(twopnts,2) == 2
		pnt1 = GeometryBasics.Point3f(twopnts[:,1])
    	pnt2 = GeometryBasics.Point3f(twopnts[:,2])
	elseif size(twopnts,1) == 2 && size(twopnts,2) == 3
		pnt1 = GeometryBasics.Point3f(twopnts[1,:])
    	pnt2 = GeometryBasics.Point3f(twopnts[2,:])
	else
		println("problem making bondshape from matrix")
	end
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end

"""
	bondshapes( structure )
	bondshapes( residues )
	bondshapes( coordinates )
	bondshapes( structure, bondmatrix )
	bondshapes( residues, bondmatrix )
	bondshapes( coordinates, bondmatrix )

Returns a (mesh) cylinder between two atoms or points.

### Keyword Arguments:
- algo ------------------ :knowledgebased | :distance, :covalent	# unless bondmatrix is given
- distance -------------- 1.9										# unless bondmatrix is given
- bondwidth ------------- 0.2
"""
function bondshapes(chn::BioStructures.Chain; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2)
	return bondshapes(BioStructures.collectatoms(chn), getbonds(chn; algo = algo, cutoff = distance); bondwidth = bondwidth)
end
function bondshapes(struc::BioStructures.MolecularStructure; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2)
	return bondshapes(BioStructures.collectatoms(struc), getbonds(struc; algo = algo, cutoff = distance); bondwidth = bondwidth)
end
function bondshapes(resz::AbstractVector{T}; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2) where {T<:BioStructures.AbstractResidue}
	return bondshapes(BioStructures.collectatoms(resz), getbonds(resz; algo = algo, cutoff = distance); bondwidth = bondwidth)
end
function bondshapes(atms::AbstractVector{T}; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
	return bondshapes(atms, getbonds(atms; algo = algo, cutoff = distance); bondwidth = bondwidth)
end
function bondshapes(resz::AbstractVector{T}; algo = :covalent, distance = 1.9, bondwidth = 0.2) where {T<:MIToS.PDB.PDBResidue}
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	return bondshapes(atms, getbonds(resz; algo = algo, cutoff = distance); bondwidth = bondwidth)
end
function bondshapes(cords::AbstractArray{T}; algo = :covalent, distance = 1.9, bondwidth = 0.2) where {T<:AbstractFloat}
	@assert size(cords,2) == 3 "coords must be an N x 3 matrix"
	return bondshapes(cords, getbonds(cords; algo = algo, cutoff = distance); bondwidth = bondwidth)
end

# --- bondshapes from a precomputed sparse bond list (Vector{Tuple{Int,Int}}), O(#bonds) ---
function bondshapes(atms::AbstractVector{T}, bonds::AbstractVector{<:Tuple{Integer,Integer}}; bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
	bshapes = Cylinder{Float32}[]
	for (i,j) in bonds
		atm1 = defaultatom(atms[i])
		atm2 = defaultatom(atms[j])
		push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(atm1.coords), GeometryBasics.Point3f(atm2.coords), Float32(bondwidth)))
	end
	return bshapes
end
function bondshapes(atms::AbstractVector{T}, bonds::AbstractVector{<:Tuple{Integer,Integer}}; bondwidth = 0.2) where {T<:MIToS.PDB.PDBAtom}
	bshapes = Cylinder{Float32}[]
	for (i,j) in bonds
		push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(atms[i].coordinates), GeometryBasics.Point3f(atms[j].coordinates), Float32(bondwidth)))
	end
	return bshapes
end
function bondshapes(cords::AbstractArray{T}, bonds::AbstractVector{<:Tuple{Integer,Integer}}; bondwidth = 0.2) where {T<:AbstractFloat}
	bshapes = Cylinder{Float32}[]
	for (i,j) in bonds
		push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(cords[i,:]), GeometryBasics.Point3f(cords[j,:]), Float32(bondwidth)))
	end
	return bshapes
end
function bondshapes(chn::BioStructures.Chain, bonds::AbstractVector{<:Tuple{Integer,Integer}}; bondwidth = 0.2)
	return bondshapes(BioStructures.collectatoms(chn), bonds; bondwidth = bondwidth)
end
function bondshapes(struc::BioStructures.MolecularStructure, bonds::AbstractVector{<:Tuple{Integer,Integer}}; bondwidth = 0.2)
	return bondshapes(BioStructures.collectatoms(struc), bonds; bondwidth = bondwidth)
end
function bondshapes(resz::AbstractVector{T}, bonds::AbstractVector{<:Tuple{Integer,Integer}}; bondwidth = 0.2) where {T<:BioStructures.AbstractResidue}
	return bondshapes(BioStructures.collectatoms(resz), bonds; bondwidth = bondwidth)
end
function bondshapes(resz::AbstractVector{T}, bonds::AbstractVector{<:Tuple{Integer,Integer}}; bondwidth = 0.2) where {T<:MIToS.PDB.PDBResidue}
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	return bondshapes(atms, bonds; bondwidth = bondwidth)
end
function bondshapes(cords::AbstractArray{T}, noth::Nothing; algo = :covalent, distance = 1.9, bondwidth = 0.2) where {T<:AbstractFloat}
	return bondshapes(cords; algo = algo, distance = distance, bondwidth = bondwidth)
end

"""
	bondmatrix( bonds, natoms ) -> BitMatrix

Convert a sparse bond list (`Vector{Tuple{Int,Int}}`, as returned by `getbonds`) into a
dense symmetric `BitMatrix`, for callers that need random `mat[i,j]` access. Allocates
O(natoms^2); only use for small atom counts.
"""
function bondmatrix(bonds::AbstractVector{<:Tuple{Integer,Integer}}, natoms::Integer)
	mat = falses(natoms, natoms)
	for (i,j) in bonds
		mat[i,j] = true
		mat[j,i] = true
	end
	return mat
end

# --- backward-compatible methods taking a dense bond matrix (legacy callers) ---
function bondshapes(chn::BioStructures.Chain, bnds::AbstractMatrix; algo = nothing, distance = nothing, bondwidth = 0.2)
	bshapes = Cylinder{Float32}[]
	atms = BioStructures.collectatoms(chn)
	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(atm1.coords), GeometryBasics.Point3f(atm2.coords), Float32(bondwidth)))
			end
		end
	end
	return bshapes
end
function bondshapes(resz::AbstractVector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:BioStructures.AbstractResidue}
	bshapes = Cylinder{Float32}[]
	atms = BioStructures.collectatoms(resz)
	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(atm1.coords), GeometryBasics.Point3f(atm2.coords), Float32(bondwidth)))
			end
		end
	end
	return bshapes
end
function bondshapes(resz::AbstractVector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:MIToS.PDB.PDBResidue}
	bshapes = Cylinder{Float32}[]
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(atms[i].coordinates), GeometryBasics.Point3f(atms[j].coordinates), Float32(bondwidth)))
			end
		end
	end
	return bshapes
end
function bondshapes(atms::AbstractVector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
	bshapes = Cylinder{Float32}[]
	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(atm1.coords), GeometryBasics.Point3f(atm2.coords), Float32(bondwidth)))
			end
		end
	end
	return bshapes
end
function bondshapes(atms::AbstractVector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:MIToS.PDB.PDBAtom}
	bshapes = Cylinder{Float32}[]
	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(atms[i].coordinates), GeometryBasics.Point3f(atms[j].coordinates), Float32(bondwidth)))
			end
		end
	end
	return bshapes
end
function bondshapes(cords::AbstractArray{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:AbstractFloat}
	@assert size(cords,2) == 3 "coords must be an N x 3 matrix"
	bshapes = Cylinder{Float32}[]
	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				push!(bshapes, GeometryBasics.Cylinder(GeometryBasics.Point3f(cords[i,:]), GeometryBasics.Point3f(cords[j,:]), Float32(bondwidth)))
			end
		end
	end
	return bshapes
end
