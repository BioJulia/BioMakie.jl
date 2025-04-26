export distancebonds,
	   covalentbonds,
	   sidechainbonds,
	   backbonebonds,
	   getbonds,
	   bondshape,
	   bondshapes

"""
	distancebonds( atms ) -> BitMatrix

Returns a matrix of all bonds in `atms`, where Mat[i,j] = 1 if atoms i and j are bonded.

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- cutoff ----------- 1.9   # distance cutoff for bonds between heavy atoms
- hydrogencutoff --- 1.14  # distance cutoff for bonds with hydrogen atoms
- H ---------------- true  # include bonds with hydrogen atoms
- disulfides ------- false # include disulfide bonds
"""
function distancebonds(atms::Vector{T};
						cutoff = 1.9,
						hydrogencutoff = 1.14,
						H = true,
						disulfides = false) where {T<:BioStructures.AbstractAtom}
	numatoms = size(atms,1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		resatoms = BioStructures.collectatoms(atms[i].residue) .|> defaultatom
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			### backbone bonds ###
			if strip(atms[i].name) in ["N","CA","C","O"] && strip(atms[j].name) in ["N","CA","C","O"]
				if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			end
			if bondmatrix[i,j] == 1
				continue
			end
			### residue bonds ###
			if atms[i].residue == atms[j].residue
				if H == true
					if !(strip(atms[i].element) == "H" || strip(atms[j].element) == "H")
						if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					else
						if euclidean(coords(atms[i]), coords(atms[j])) < hydrogencutoff
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					end
				else
					if !(strip(atms[i].element) == "H" || strip(atms[j].element) == "H")
						if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
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
				if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
					if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
						bondmatrix[i,k] = 1
						bondmatrix[k,i] = 1
					end
				end
			end
		end
	end

	return bondmatrix
end
function distancebonds(resz::Vector{T};
						cutoff = 1.9,
						hydrogencutoff = 1.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBResidue}
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	resindices = [[i for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	resnames = [[resz[i].id.name for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	numatoms = size(atms,1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		resatoms = bestoccupancy(resz[resindices[i]].atoms)
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			if atms[i].atom in ["N","CA","C","O"] && atms[j].atom in ["N","CA","C","O"]
				if euclidean(atms[i].coordinates, atms[j].coordinates) < cutoff
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			end
			if bondmatrix[i,j] == 1
				continue
			end
			if resindices[i] == resindices[j]
				if H == true
					if atms[i].element == "H" || atms[j].element == "H"
						if euclidean(atms[i].coordinates,atms[j].coordinates) < hydrogencutoff
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					elseif !(atms[i].element == "H" || atms[j].element == "H")
						if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
						end
					end
				else
					if !(atms[i].element == "H" || atms[j].element == "H")
						if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
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
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
						bondmatrix[i,k] = 1
						bondmatrix[k,i] = 1
					end
				end
			end
		end
	end

	return bondmatrix
end
function distancebonds(atms::Vector{T};
						cutoff = 1.9,
						hydrogencutoff = 1.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBAtom}
	numatoms = size(atms,1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		for j in (i+1):numatoms
			if H == true
				if atms[i].element == "H" || atms[j].element == "H"
					if euclidean(atms[i].coordinates,atms[j].coordinates) < hydrogencutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				elseif !(atms[i].element == "H" || atms[j].element == "H")
					if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
			else
				if !(atms[i].element == "H" || atms[j].element == "H")
					if euclidean(atms[i].coordinates,atms[j].coordinates) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
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
	covalentbonds( atms ) -> BitMatrix

Returns a matrix of all bonds in `atms`, where Mat[i,j] = 1 if atoms i and j are bonded.

This function uses 'bestoccupancy' or 'defaultatom' to ensure only one position per atom.

### Keyword Arguments:
- extradistance ---- 0.14  # fudge factor for better inclusion
- H ---------------- true  # include bonds with hydrogen atoms
- disulfides ------- false # include disulfide bonds
"""
function covalentbonds(atms::Vector{T};
						extradistance = 0.14,
						H = true,
						disulfides = false) where {T<:BioStructures.AbstractAtom}
	numatoms = size(atms,1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		resatoms = BioStructures.collectatoms(atms[i].residue) .|> defaultatom
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			### backbone bonds ###
			if strip(atms[i].name) in ["N","CA","C","O"] && strip(atms[j].name) in ["N","CA","C","O"]
				if euclidean(coords(atms[i]), coords(atms[j])) < (covalentradii[BioStructures.element(atms[i])] +
						covalentradii[BioStructures.element(atms[j])] + extradistance)
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			end
			if bondmatrix[i,j] == 1
				continue
			end
			### residue bonds ###
			if atms[i].residue == atms[j].residue
				if H == true
					if euclidean(coords(atms[i]), coords(atms[j])) < (covalentradii[strip(atms[i].element)] +
							covalentradii[strip(atms[j].element)] + extradistance)
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				else
					if !(strip(atms[i].element) == "H" || strip(atms[j].element) == "H")
						if euclidean(coords(atms[i]), coords(atms[j])) < (covalentradii[strip(atms[i].element)] +
								covalentradii[strip(atms[j].element)] + extradistance)
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
				if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
					if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
						bondmatrix[i,k] = 1
						bondmatrix[k,i] = 1
					end
				end
			end
		end
	end

	return bondmatrix
end
function covalentbonds(resz::Vector{T};
						extradistance = 0.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBResidue}
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten
	resindices = [[i for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	resnames = [[resz[i].id.name for j in 1:size(bestoccupancy(resz[i].atoms),1)] for i in 1:length(resz)] |> flatten
	numatoms = size(atms,1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		resatoms = bestoccupancy(resz[resindices[i]].atoms)
		numresatoms = size(resatoms,1)
		nextresatms = (i+numresatoms)
		if (i+numresatoms) > numatoms
			nextresatms = numatoms
		end
		for j in (i+1):nextresatms
			### backbone bonds ###
			if atms[i].atom in ["N","CA","C","O"] && atms[j].atom in ["N","CA","C","O"]
				if euclidean(atms[i].coordinates, atms[j].coordinates) < (covalentradii[atms[i].element] +
						covalentradii[atms[j].element] + extradistance)
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			end
			if bondmatrix[i,j] == 1
				continue
			end
			### residue bonds ###
			if resindices[i] == resindices[j]
				if H == true
					if euclidean(atms[i].coordinates,atms[j].coordinates) < (covalentradii[atms[i].element] +
							covalentradii[atms[j].element] + extradistance)
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				else
					if !(atms[i].element == "H" || atms[j].element == "H")
						if euclidean(atms[i].coordinates,atms[j].coordinates) < (covalentradii[atms[i].element] +
								covalentradii[atms[j].element] + extradistance)
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
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
						bondmatrix[i,k] = 1
						bondmatrix[k,i] = 1
					end
				end
			end
		end
	end

	return bondmatrix
end
function covalentbonds(atms::Vector{T};
						extradistance = 0.14,
						H = true,
						disulfides = false) where {T<:MIToS.PDB.PDBAtom}
	numatoms = size(atms,1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		for j in (i+1):numatoms
			if H == true
				if euclidean(atms[i].coordinates,atms[j].coordinates) < (covalentradii[atms[i].element] +
						covalentradii[atms[j].element] + extradistance)
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			else
				if !(atms[i].element == "H" || atms[j].element == "H")
					if euclidean(atms[i].coordinates,atms[j].coordinates) < (covalentradii[atms[i].element] +
							covalentradii[atms[j].element] + extradistance)
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
			end
		end
		### disulfide bonds ###
		if disulfides == true
			for k in 1:numatoms
				if i != k && atms[i].element == "S" && atms[k].element == "S"
					if euclidean(atms[i].coordinates, atms[k].coordinates) < 2.1
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
	sidechainbonds( res::BioStructures.AbstractResidue, selectors... ) -> BitMatrix

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
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

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
				if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						bondmatrix[i,j] = 0
						bondmatrix[j,i] = 0
					end
				end
				if bondmatrix[i,j] == 1
					continue
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					heavybondresz = heavyresbonds[atmres.name] |> combinedims
					heavylength = size(heavybondresz,2)
					for k in 1:heavylength
						if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
								firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
					### hydrogen atoms ###
					if H == true
						hbondresz = hresbonds[atmres.name] |> combinedims
						if size(hbondresz,1) <= 1
							continue
						end
						hlength = size(hbondresz,2)
						for k in 1:hlength
							if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
								bondmatrix[i,j] = 1
								bondmatrix[j,i] = 1
								break
							end
						end
					end
				end
			end
		end
		return bondmatrix
	elseif algo == :distance
		return distancebonds(resatoms; cutoff = cutoff, H = H)
	elseif algo == :covalent
		return covalentbonds(resatoms; extradistance = extradistance, H = H)
	else # just do the same as :covalent for now
		return covalentbonds(resatoms; extradistance = extradistance, H = H)
	end
end

"""
	backbonebonds( chn::BioStructures.Chain ) -> BitMatrix

Returns a matrix of backbone bonds in `chn`, where Mat[i,j] = 1 if atoms i and j are bonded.

### Keyword Arguments:
- cutoff ----------- 1.6		# distance cutoff for bonds
"""
function backbonebonds(chn::BioStructures.Chain; cutoff = 1.6)
	bbatoms = BioStructures.collectatoms(chn, backboneselector) .|> defaultatom
	bondmatrix = zeros(size(bbatoms,1),size(bbatoms,1)) |> BitMatrix

	for i in 1:size(bbatoms,1)
		for j in (i+1):size(bbatoms,1)
			firstatomname = strip(bbatoms[i].name)
			secondatomname = strip(bbatoms[j].name)
			if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
				if euclidean(coordarray(bbatoms[i]) |> transpose |> collect, coordarray(bbatoms[j]) |> transpose |> collect) < cutoff
					bondmatrix[i,j] = 1
					bondmatrix[j,i] = 1
				end
			end
		end
	end

	return bondmatrix
end

"""
	getbonds( chn::BioStructures.Chain, selectors... ) -> BitMatrix
	getbonds( modl::BioStructures.Model, selectors... ) -> BitMatrix
	getbonds( struc::BioStructures.MolecularStructure, selectors... ) -> BitMatrix

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
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

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
				if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
				if bondmatrix[i,j] == 1
					continue
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					heavybondresz = heavyresbonds[atmres.name] |> combinedims
					heavylength = size(heavybondresz,2)
					for k in 1:heavylength
						if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
								firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
					### hydrogen atoms ###
					if H == true
						hbondresz = hresbonds[atmres.name] |> combinedims
						if size(hbondresz,1) <= 1
							continue
						end
						hlength = size(hbondresz,2)
						for k in 1:hlength
							if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
								bondmatrix[i,j] = 1
								bondmatrix[j,i] = 1
								break
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
							bondmatrix[i,k] = 1
							bondmatrix[k,i] = 1
						end
					end
				end
			end
		end
		return bondmatrix
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
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

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
				if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
				if bondmatrix[i,j] == 1
					continue
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					heavybondresz = heavyresbonds[atmres.name] |> combinedims
					heavylength = size(heavybondresz,2)
					for k in 1:heavylength
						if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
								firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
					### hydrogen atoms ###
					if H == true
						hbondresz = hresbonds[atmres.name] |> combinedims
						if size(hbondresz,1) <= 1
							continue
						end
						hlength = size(hbondresz,2)
						for k in 1:hlength
							if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
								bondmatrix[i,j] = 1
								bondmatrix[j,i] = 1
								break
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
							bondmatrix[i,k] = 1
							bondmatrix[k,i] = 1
						end
					end
				end
			end
		end
		return bondmatrix
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
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

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
				if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
				if bondmatrix[i,j] == 1
					continue
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					heavybondresz = heavyresbonds[atmres.name] |> combinedims
					heavylength = size(heavybondresz,2)
					for k in 1:heavylength
						if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
								firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
					### hydrogen atoms ###
					if H == true
						hbondresz = hresbonds[atmres.name] |> combinedims
						if size(hbondresz,1) <= 1
							continue
						end
						hlength = size(hbondresz,2)
						for k in 1:hlength
							if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
								bondmatrix[i,j] = 1
								bondmatrix[j,i] = 1
								break
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
							bondmatrix[i,k] = 1
							bondmatrix[k,i] = 1
						end
					end
				end
			end
		end
		return bondmatrix
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
	getbonds( residues ) -> BitMatrix

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
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix
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
				if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
					if euclidean(atms[i].coordinates |> collect, atms[j].coordinates |> collect) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
				### residue atoms ###
				if bondmatrix[i,j] == 1
					continue
				end
				if resindices[i] == resindices[j]
					heavybondresz = heavyresbonds[resnames[i]] |> combinedims
					heavylength = size(heavybondresz,2)
					for k in 1:heavylength
						if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
								firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
				end
				### hydrogen atoms ###
				if H == true
					hbondresz = hresbonds[resnames[i]] |> combinedims
					if size(hbondresz,1) <= 1
						continue
					end
					hlength = size(hbondresz,2)
					for k in 1:hlength
						if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
				end
			end
			### disulfide bonds ###
			if disulfides == true
				for k in 1:numatoms
					if i != k && strip(atms[i].element) == "S" && strip(atms[k].element) == "S"
						if euclidean(coords(atms[i]), coords(atms[k])) < 2.1
							bondmatrix[i,k] = 1
							bondmatrix[k,i] = 1
						end
					end
				end
			end
		end
		return bondmatrix
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
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix
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
function getbonds(resz::Vector{T};
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false) where {T<:BioStructures.AbstractResidue}

	atms = BioStructures.collectatoms(resz) .|> defaultatom
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

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
				if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
				if bondmatrix[i,j] == 1
					continue
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					heavybondresz = heavyresbonds[atmres.name] |> combinedims
					heavylength = size(heavybondresz,2)
					for k in 1:heavylength
						if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
								firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
					### hydrogen atoms ###
					if H == true
						hbondresz = hresbonds[atmres.name] |> combinedims
						if size(hbondresz,1) <= 1
							continue
						end
						hlength = size(hbondresz,2)
						for k in 1:hlength
							if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
								bondmatrix[i,j] = 1
								bondmatrix[j,i] = 1
								break
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
							bondmatrix[i,k] = 1
							bondmatrix[k,i] = 1
						end
					end
				end
			end
		end
		return bondmatrix
	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end
function getbonds(atms::Vector{T};
				algo = :knowledgebased,
				H = true,
				cutoff = 1.9,
				extradistance = 0.14,
				disulfides = false) where {T<:BioStructures.AbstractAtom}

	atms = atms .|> defaultatom
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

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
				if firstatomname in ["N","CA","C","O"] && secondatomname in ["N","CA","C","O"]
					if euclidean(coords(atms[i]), coords(atms[j])) < cutoff
						bondmatrix[i,j] = 1
						bondmatrix[j,i] = 1
					end
				end
				if bondmatrix[i,j] == 1
					continue
				end
				### residue atoms ###
				if atms[i].residue == atms[j].residue
					atmres = atms[i].residue
					heavybondresz = heavyresbonds[atmres.name] |> combinedims
					heavylength = size(heavybondresz,2)
					for k in 1:heavylength
						if firstatomname == heavybondresz[1,k] && secondatomname == heavybondresz[2,k] ||
								firstatomname == heavybondresz[2,k] && secondatomname == heavybondresz[1,k]
							bondmatrix[i,j] = 1
							bondmatrix[j,i] = 1
							break
						end
					end
					### hydrogen atoms ###
					if H == true
						hbondresz = hresbonds[atmres.name] |> combinedims
						if size(hbondresz,1) <= 1
							continue
						end
						hlength = size(hbondresz,2)
						for k in 1:hlength
							if firstatomname == hbondresz[1,k] && secondatomname == hbondresz[2,k]
								bondmatrix[i,j] = 1
								bondmatrix[j,i] = 1
								break
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
							bondmatrix[i,k] = 1
							bondmatrix[k,i] = 1
						end
					end
				end
			end
		end
		return bondmatrix
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
	getbonds( coords ) -> BitMatrix

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
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

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
	pnt1 = GeometryBasics.Point3f0(atm1.coords)
    pnt2 = GeometryBasics.Point3f0(atm2.coords)
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end
function bondshape(twoatoms::AbstractVector{T}; bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
    @assert length(twoatoms) == 2
	atm1 = defaultatom(twoatoms[1])
	atm2 = defaultatom(twoatoms[2])
	pnt1 = GeometryBasics.Point3f0(atm1.coords)
    pnt2 = GeometryBasics.Point3f0(atm2.coords)
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end
function bondshape(twopnts::Vector{T}; bondwidth = 0.2) where {T<:GeometryBasics.AbstractPoint}
    @assert length(twopnts) == 2
	pnt1 = GeometryBasics.Point3f0(twopnts[1])
    pnt2 = GeometryBasics.Point3f0(twopnts[2])
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end
function bondshape(twopnts::AbstractMatrix{T}; bondwidth = 0.2) where {T<:AbstractFloat}
    if size(twopnts,1) == 3 && size(twopnts,2) == 2
		pnt1 = GeometryBasics.Point3f0(twopnts[:,1])
    	pnt2 = GeometryBasics.Point3f0(twopnts[:,2])
	elseif size(twopnts,1) == 2 && size(twopnts,2) == 3
		pnt1 = GeometryBasics.Point3f0(twopnts[1,:])
    	pnt2 = GeometryBasics.Point3f0(twopnts[2,:])
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
    bshapes = Cylinder3{Float32}[]
	bnds = getbonds(chn; algo = algo, cutoff = distance)
	atms = BioStructures.collectatoms(chn)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				pnt1 = GeometryBasics.Point3f0(atm1.coords)
				pnt2 = GeometryBasics.Point3f0(atm2.coords)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(struc::BioStructures.MolecularStructure; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2)
	bshapes = Cylinder3{Float32}[]
	bnds = getbonds(struc; algo = algo, cutoff = distance)
	atms = BioStructures.collectatoms(struc)

	for k in 1:size(bnds,1)
		for i in 1:size(bnds[k],1)
			for j in (i+1):size(bnds[k],1)
				if bnds[k][i,j] == 1 && i != j
					atm1 = defaultatom(atms[k][i])
					atm2 = defaultatom(atms[k][j])
					pnt1 = GeometryBasics.Point3f0(atm1.coords)
					pnt2 = GeometryBasics.Point3f0(atm2.coords)
					push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
				end
			end
		end
	end

    return bshapes
end
function bondshapes(resz::Vector{T}; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2) where {T<:BioStructures.AbstractResidue}
	bshapes = Cylinder3{Float32}[]
	bnds = getbonds(resz; algo = algo, cutoff = distance)
	atms = BioStructures.collectatoms(resz)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				pnt1 = GeometryBasics.Point3f0(atm1.coords)
				pnt2 = GeometryBasics.Point3f0(atm2.coords)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(atms::Vector{T}; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
	bshapes = Cylinder3{Float32}[]
	bnds = getbonds(atms; algo = algo, cutoff = distance)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				pnt1 = GeometryBasics.Point3f0(atm1.coords)
				pnt2 = GeometryBasics.Point3f0(atm2.coords)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(resz::Vector{T}; algo = :covalent, distance = 1.9, bondwidth = 0.2) where {T<:MIToS.PDB.PDBResidue}
    bshapes = Cylinder3{Float32}[]
	bnds = getbonds(resz; algo = algo, cutoff = distance)
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = atms[i]
				atm2 = atms[j]
				pnt1 = GeometryBasics.Point3f0(atm1.coordinates)
				pnt2 = GeometryBasics.Point3f0(atm2.coordinates)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(chn::BioStructures.Chain, bnds::AbstractMatrix; algo = nothing, distance = nothing, bondwidth = 0.2)
    bshapes = Cylinder3{Float32}[]
	atms = BioStructures.collectatoms(chn)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				pnt1 = GeometryBasics.Point3f0(atm1.coords)
				pnt2 = GeometryBasics.Point3f0(atm2.coords)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(struc::BioStructures.MolecularStructure, bnds::AbstractMatrix; algo = nothing, cutoff = nothing, bondwidth = 0.2)
	bshapes = Cylinder3{Float32}[]
	atms = BioStructures.collectatoms(struc)

	for k in 1:size(bnds,1)
		for i in 1:size(bnds[k],1)
			for j in (i+1):size(bnds[k],1)
				if bnds[k][i,j] == 1 && i != j
					atm1 = defaultatom(atms[k][i])
					atm2 = defaultatom(atms[k][j])
					pnt1 = GeometryBasics.Point3f0(atm1.coords)
					pnt2 = GeometryBasics.Point3f0(atm2.coords)
					push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
				end
			end
		end
	end

    return bshapes
end
function bondshapes(resz::Vector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:BioStructures.AbstractResidue}
	bshapes = Cylinder3{Float32}[]
	atms = BioStructures.collectatoms(resz)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				pnt1 = GeometryBasics.Point3f0(atm1.coords)
				pnt2 = GeometryBasics.Point3f0(atm2.coords)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(resz::Vector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:MIToS.PDB.PDBResidue}
    bshapes = Cylinder3{Float32}[]
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = atms[i]
				atm2 = atms[j]
				pnt1 = GeometryBasics.Point3f0(atm1.coordinates)
				pnt2 = GeometryBasics.Point3f0(atm2.coordinates)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(atms::Vector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
	bshapes = Cylinder3{Float32}[]

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = defaultatom(atms[i])
				atm2 = defaultatom(atms[j])
				pnt1 = GeometryBasics.Point3f0(atm1.coords)
				pnt2 = GeometryBasics.Point3f0(atm2.coords)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(atms::Vector{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:MIToS.PDB.PDBAtom}
    bshapes = Cylinder3{Float32}[]

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				atm1 = atms[i]
				atm2 = atms[j]
				pnt1 = GeometryBasics.Point3f0(atm1.coordinates)
				pnt2 = GeometryBasics.Point3f0(atm2.coordinates)
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(cords::AbstractArray{T}; algo = :covalent, distance = 1.9, bondwidth = 0.2) where {T<:AbstractFloat}
	@assert size(cords,2) == 3 "coords must be an N x 3 matrix"
    bshapes = Cylinder3{Float32}[]
	bnds = getbonds(cords; algo = algo, cutoff = distance)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				pnt1 = GeometryBasics.Point3f0(cords[i,:])
				pnt2 = GeometryBasics.Point3f0(cords[j,:])
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(cords::AbstractArray{T}, bnds::AbstractMatrix; bondwidth = 0.2) where {T<:AbstractFloat}
	@assert size(cords,2) == 3 "coords must be an N x 3 matrix"
    bshapes = Cylinder3{Float32}[]

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				pnt1 = GeometryBasics.Point3f0(cords[i,:])
				pnt2 = GeometryBasics.Point3f0(cords[j,:])
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end
function bondshapes(cords::AbstractArray{T}, noth::Nothing; algo = :covalent, distance = 1.9, bondwidth = 0.2) where {T<:AbstractFloat}
	@assert size(cords,2) == 3 "coords must be an N x 3 matrix"
    bshapes = Cylinder3{Float32}[]
	bnds = getbonds(cords; algo = algo, cutoff = distance)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1 && i != j
				pnt1 = GeometryBasics.Point3f0(cords[i,:])
				pnt2 = GeometryBasics.Point3f0(cords[j,:])
				push!(bshapes, GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth)))
			end
		end
	end

    return bshapes
end