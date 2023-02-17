export distancebonds,
	   covalentbonds,
	   sidechainbonds,
	   backbonebonds,
	   getbonds,
	   bondshape,
	   bondshapes

"""
	distancebonds( atms::Vector{T} )

Returns a matrix of all bonds in `atms`. 

### Optional Arguments:
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
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		resatoms = collectatoms(atms[i].residue) .|> defaultatom
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
	numatoms = size(atms, 1)
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

"""
	covalentbonds( atms::Vector{T} )

Returns a matrix of all bonds in `atms`. 

### Optional Arguments:
- extradistance ---- 0.14  # fudge factor for better inclusion
- H ---------------- true  # include bonds with hydrogen atoms
- disulfides ------- false # include disulfide bonds
"""
function covalentbonds(atms::Vector{T}; 
						extradistance = 0.14, 
						H = true,
						disulfides = false) where {T<:BioStructures.AbstractAtom}
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	for i in 1:numatoms
		resatoms = collectatoms(atms[i].residue) .|> defaultatom
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
	numatoms = size(atms, 1)
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

"""
	sidechainbonds( res::BioStructures.AbstractResidue, selectors... )

Returns a matrix of sidechain bonds in `res`. 

### Optional Arguments:
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
	atms = collectatoms(res, selectors...) .|> defaultatom
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = collectatoms(atms[i].residue, selectors...) .|> defaultatom
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
	backbonebonds( chn::BioStructures.Chain )

Returns a matrix of backbone bonds in `chn`. 

### Optional Arguments:
- cutoff ----------- 1.6		# distance cutoff for bonds
"""
function backbonebonds(chn::BioStructures.Chain; cutoff = 1.6)
	bbatoms = collectatoms(chn, backboneselector) .|> defaultatom
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
	getbonds( chn::BioStructures.Chain )

Returns a matrix of all bonds in `atms`. 

### Optional Arguments:
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
	atms = collectatoms(chn, selectors...) .|> defaultatom
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix

	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = collectatoms(atms[i].residue, selectors...) .|> defaultatom
			numresatoms = size(resatoms,1)
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
		return distancebonds(atms; cutoff = cutoff, H = H, disulfides = disulfides)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance, H = H, disulfides = disulfides)
	end

	return nothing
end

"""
	getbonds( resz::Vector{MIToS.PDB.PDBResidue} )

Returns a matrix of all bonds in `resz`. 

### Optional Arguments:
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
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix
	if algo == :knowledgebased
		for i in 1:numatoms
			resatoms = bestoccupancy(resz[resindices[i]].atoms)
			numresatoms = size(resatoms,1)
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
"""
	getbonds( resz::Vector{BioStructures.AbstractResidue} )

Returns a matrix of all intra-residue bonds in `resz`. 
Utilizes `sidechainbonds` to get bonds within each residue.

### Optional Arguments:
- kwargs...			# passed to `sidechainbonds`
"""
function getbonds(resz::Vector{T}; kwargs...) where {T<:BioStructures.AbstractResidue}
	return sidechainbonds.(resz; kwargs...)
end
# Default bond shape is a cylinder mesh. TODO: maybe add double and triple bond shapes.
function bondshape(twoatoms::Tuple{T}; bondwidth = 0.2) where {T<:BioStructures.AbstractAtom}
    @assert length(twoatoms) == 2
	atm1 = defaultatom(twoatoms[1])
	atm2 = defaultatom(twoatoms[2])
	pnt1 = GeometryBasics.Point3f0(atm1.coords)
    pnt2 = GeometryBasics.Point3f0(atm2.coords)
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
function bondshapes(chn::BioStructures.Chain, selectors...; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2)
    bshapes = Cylinder3{Float32}[]
	bnds = getbonds(chn, selectors...; algo = algo, cutoff = distance)
	atms = collectatoms(chn, selectors...)

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1
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
function bondshapes(struc::BioStructures.ProteinStructure, selectors...; algo = :knowledgebased, distance = 1.9, bondwidth = 0.2)
	bshapes = Cylinder3{Float32}[]
	chns = collectchains(struc)
	bnds = getbonds.(chns, selectors...; algo = algo, cutoff = distance)
	atms = collectatoms.(chns, selectors...)

	for k in 1:size(bnds,1)
		for i in 1:size(bnds[k],1)
			for j in (i+1):size(bnds[k],1)
				if bnds[k][i,j] == 1
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
function bondshapes(resz::Vector{MIToS.PDB.PDBResidue}; algo = :covalent, distance = 1.9, bondwidth = 0.2)
    bshapes = Cylinder3{Float32}[]
	bnds = getbonds(resz; algo = algo, cutoff = distance)
	atms = [bestoccupancy(resz[i].atoms) for i in 1:length(resz)] |> flatten

	for i in 1:size(bnds,1)
		for j in (i+1):size(bnds,1)
			if bnds[i,j] == 1
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