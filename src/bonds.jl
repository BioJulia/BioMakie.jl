export distancebonds,
	   covalentbonds,
	   sidechainbonds,
	   backbonebonds,
	   getbonds,
	   bondshape,
	   bondshapes

function distancebonds(atms::Vector{T}; cutoff = 1.9, hydrogencutoff = 1.14) where {T<:BioStructures.AbstractAtom}
    mat = zeros(length(atms),length(atms)) |> BitMatrix

    for (i,a1) in enumerate(atms), (j,a2) in enumerate(atms)
		if BioStructures.element(a1) == "H" || BioStructures.element(a2) == "H"
			if i != j && euclidean(coords(a1),coords(a2)) < hydrogencutoff
				mat[i,j] = 1
			end
		else
			if i != j && euclidean(coords(a1),coords(a2)) < cutoff
				mat[i,j] = 1
			end
		end
    end

    return mat
end
function covalentbonds(atms::Vector{T}; extradistance = 0.05) where {T<:BioStructures.AbstractAtom}
    mat = zeros(length(atms),length(atms)) |> BitMatrix

    for (i,a1) in enumerate(atms), (j,a2) in enumerate(atms)
		if i != j && euclidean(coords(a1),coords(a2)) < (covalentradii[BioStructures.element(a1)] + covalentradii[BioStructures.element(a2)] + extradistance) 
            mat[i,j] = 1
        end
    end

    return mat
end
function sidechainbonds(res::BioStructures.AbstractResidue, selectors...; 
						algo = :knowledgebased, 
						H = true,
						cutoff = 1.9,
						extradistance = 0.05)
	resatomdict = res.atoms
	resatoms = collectatoms(res, selectors...) .|> defaultatom
	numatoms = size(resatoms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix
	resatmkeys = strip.([resatoms[i].name for i in 1:size(resatoms,1)]) .|> string
	srl2idx = Dict([(resatoms[i].serial => i) for i in 1:size(resatoms,1)])
	serial2index(ser) = srl2idx[ser]

	if algo == :knowledgebased
		position1 = nothing
		position2 = nothing
		for heavybond in heavyresbonds[res.name]
			firstatomname = "$(heavybond[1])"
			secondatomname = "$(heavybond[2])"
			if firstatomname in resatmkeys && secondatomname in resatmkeys
				if length(heavybond[1]) == 1
					firstatomname = " $(heavybond[1])  "
				elseif length(heavybond[1]) == 2
					firstatomname = " $(heavybond[1]) "
				elseif length(heavybond[1]) == 3
					firstatomname = " $(heavybond[1])"
				elseif length(heavybond[1]) == 4
					firstatomname = "$(heavybond[1])"
				else
					# println("unusual atom $(heavybond[1])")
				end
				if length(heavybond[2]) == 1
					secondatomname = " $(heavybond[2])  "
				elseif length(heavybond[2]) == 2
					secondatomname = " $(heavybond[2]) "
				elseif length(heavybond[2]) == 3
					secondatomname = " $(heavybond[2])"
				elseif length(heavybond[2]) == 4
					secondatomname = "$(heavybond[2])"
				else
					# println("unusual atom $(heavybond[2])")
				end
				position1 = defaultatom(resatomdict[firstatomname]).serial |> serial2index
				position2 = defaultatom(resatomdict[secondatomname]).serial |> serial2index
				bondmatrix[position1,position2] = 1
				bondmatrix[position2,position1] = 1
			end
		end
		if H == true
			for hresbond in hresbonds[res.name]
				firstatomname = "$(hresbond[1])"
				secondatomname = "$(hresbond[2])"
				if firstatomname in resatmkeys && secondatomname in resatmkeys
					if length(hresbond[1]) == 1
						firstatomname = " $(hresbond[1])  "
					elseif length(hresbond[1]) == 2
						firstatomname = " $(hresbond[1]) "
					elseif length(hresbond[1]) == 3
						firstatomname = " $(hresbond[1])"
					elseif length(hresbond[1]) == 4
						firstatomname = "$(hresbond[1])"
					else
						# println("unusual atom $(hresbond[1])")
					end
					if length(hresbond[2]) == 1
						secondatomname = " $(hresbond[2])  "
					elseif length(hresbond[2]) == 2
						secondatomname = " $(hresbond[2]) "
					elseif length(hresbond[2]) == 3
						secondatomname = " $(hresbond[2])"
					elseif length(hresbond[2]) == 4
						secondatomname = "$(hresbond[2])"
					else
						# println("unusual atom $(hresbond[2])")
					end
					position1 = defaultatom(resatomdict[firstatomname]).serial |> serial2index
					position2 = defaultatom(resatomdict[secondatomname]).serial |> serial2index
					bondmatrix[position1,position2] = 1
					bondmatrix[position2,position1] = 1
				end
			end
		end
		return bondmatrix

	elseif algo == :distance
		return distancebonds(resatoms; cutoff = cutoff)
	elseif algo == :covalent
		return covalentbonds(resatoms; extradistance = extradistance)
	else # just do the same as :covalent for now
		return covalentbonds(resatoms; extradistance = extradistance)
	end
end
function backbonebonds(chn::BioStructures.Chain; cutoff = 1.6)
	bbatoms = collectatoms(chn, backboneselector) .|> defaultatom
	bondmatrix = zeros(size(bbatoms,1),size(bbatoms,1)) |> BitMatrix

	for i = 1:(size(bbatoms,1)-1)
		firstatomname = bbatoms[i].name
		secondatomname = bbatoms[i+1].name
		if firstatomname == " N  " && secondatomname == " CA " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < cutoff
			bondmatrix[i,(i+1)] = 1
			bondmatrix[(i+1),i] = 1
		elseif firstatomname == " CA " && secondatomname == " C  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < cutoff
			bondmatrix[i,(i+1)] = 1
			bondmatrix[(i+1),i] = 1
		elseif firstatomname == " C  " && secondatomname == " O  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < cutoff
			bondmatrix[i,(i+1)] = 1
			bondmatrix[(i+1),i] = 1
		elseif firstatomname == " N  " && bbatoms[i-2].name ==  " C  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i-2])) < cutoff
			try	
				bondmatrix[i,i-2] = 1
				bondmatrix[i-2,i] = 1
			catch
			end
		else
		end
	end

	return bondmatrix
end
function getbonds(residues::AbstractArray{T}; kwargs...) where {T<:BioStructures.AbstractResidue}
	return sidechainbonds.(residues; kwargs...)
end
function getbonds(chn::BioStructures.Chain, selectors...;
				  algo = :covalent, 
				  H = true,
				  cutoff = 1.9,
				  extradistance = 0.05)
	# this could definitely use some optimization...
	atms = collectatoms(chn, selectors...) .|> defaultatom
	numatoms = size(atms, 1)
	bondmatrix = zeros(numatoms, numatoms) |> BitMatrix
	atmkeys = strip.([atms[i].name for i in 1:size(atms,1)]) .|> string
	srl2idx = Dict([(atms[i].serial => i) for i in 1:size(atms,1)])
	serial2index(ser) = srl2idx[ser]

	if algo == :knowledgebased
		reslist = collectresidues(chn, standardselector) .|> defaultresidue
		for res in reslist
			resatomdict = res.atoms
			resatoms = collectatoms(res, selectors...) .|> defaultatom
			numresatoms = size(resatoms, 1)
			resatmkeys = strip.([resatoms[i].name for i in 1:size(resatoms,1)]) .|> string
			position1 = nothing
			position2 = nothing
			for heavybond in heavyresbonds[res.name]
				firstatomname = "$(heavybond[1])"
				secondatomname = "$(heavybond[2])"
				if firstatomname in resatmkeys && secondatomname in resatmkeys
					if length(heavybond[1]) == 1
						firstatomname = " $(heavybond[1])  "
					elseif length(heavybond[1]) == 2
						firstatomname = " $(heavybond[1]) "
					elseif length(heavybond[1]) == 3
						firstatomname = " $(heavybond[1])"
					elseif length(heavybond[1]) == 4
						firstatomname = "$(heavybond[1])"
					else
						# println("unusual atom $(heavybond[1])")
					end
					if length(heavybond[2]) == 1
						secondatomname = " $(heavybond[2])  "
					elseif length(heavybond[2]) == 2
						secondatomname = " $(heavybond[2]) "
					elseif length(heavybond[2]) == 3
						secondatomname = " $(heavybond[2])"
					elseif length(heavybond[2]) == 4
						secondatomname = "$(heavybond[2])"
					else
						# println("unusual atom $(heavybond[2])")
					end
					position1 = defaultatom(resatomdict[firstatomname]).serial |> serial2index
					position2 = defaultatom(resatomdict[secondatomname]).serial |> serial2index
					bondmatrix[position1,position2] = 1
					bondmatrix[position2,position1] = 1
				end
			end
			if H == true
				for hresbond in hresbonds[res.name]
					firstatomname = "$(hresbond[1])"
					secondatomname = "$(hresbond[2])"
					if firstatomname in resatmkeys && secondatomname in resatmkeys
						if length(hresbond[1]) == 1
							firstatomname = " $(hresbond[1])  "
						elseif length(hresbond[1]) == 2
							firstatomname = " $(hresbond[1]) "
						elseif length(hresbond[1]) == 3
							firstatomname = " $(hresbond[1])"
						elseif length(hresbond[1]) == 4
							firstatomname = "$(hresbond[1])"
						else
							# println("unusual atom $(hresbond[1])")
						end
						if length(hresbond[2]) == 1
							secondatomname = " $(hresbond[2])  "
						elseif length(hresbond[2]) == 2
							secondatomname = " $(hresbond[2]) "
						elseif length(hresbond[2]) == 3
							secondatomname = " $(hresbond[2])"
						elseif length(hresbond[2]) == 4
							secondatomname = "$(hresbond[2])"
						else
							# println("unusual atom $(hresbond[2])")
						end
						position1 = defaultatom(resatomdict[firstatomname]).serial |> serial2index
						position2 = defaultatom(resatomdict[secondatomname]).serial |> serial2index
						bondmatrix[position1,position2] = 1
						bondmatrix[position2,position1] = 1
					end
				end
			end
		end
		for i = 1:(size(atms,1)-1)
			firstatomname = atms[i].name
			secondatomname = atms[i+1].name
			if firstatomname == " N  " && secondatomname == " CA " && euclidean(atomcoords(atms[i]), atomcoords(atms[i+1])) < cutoff
				bondmatrix[i,(i+1)] = 1
				bondmatrix[(i+1),i] = 1
			elseif firstatomname == " CA " && secondatomname == " C  " && euclidean(atomcoords(atms[i]), atomcoords(atms[i+1])) < cutoff
				bondmatrix[i,(i+1)] = 1
				bondmatrix[(i+1),i] = 1
			elseif firstatomname == " C  " && secondatomname == " O  " && euclidean(atomcoords(atms[i]), atomcoords(atms[i+1])) < cutoff
				bondmatrix[i,(i+1)] = 1
				bondmatrix[(i+1),i] = 1
			elseif firstatomname == " N  " && atms[i-2].name ==  " C  " && euclidean(atomcoords(atms[i]), atomcoords(atms[i-2])) < cutoff
				try	
					bondmatrix[i,i-2] = 1
					bondmatrix[i-2,i] = 1
				catch
				end
			else
			end
		end
		return bondmatrix

	elseif algo == :distance
		return distancebonds(atms; cutoff = cutoff)
	elseif algo == :covalent
		return covalentbonds(atms; extradistance = extradistance)
	else # just do the same as :covalent for now
		return covalentbonds(atms; extradistance = extradistance)
	end

	return nothing
end
# Default bond shape is a cylinder mesh. TODO: maybe add double and triple bond shapes.
function bondshape(twoatoms::Tuple{T}; bondwidth = 0.3) where {T<:BioStructures.AbstractAtom}
    @assert length(twoatoms) == 2
	atm1 = defaultatom(twoatoms[1])
	atm2 = defaultatom(twoatoms[2])
	pnt1 = GeometryBasics.Point3f0(atm1.coords)
    pnt2 = GeometryBasics.Point3f0(atm2.coords)
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end
function bondshape(twopnts::AbstractMatrix{T}; bondwidth = 0.3) where {T<:AbstractFloat}
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
function bondshapes(chn::BioStructures.Chain, selectors...; algo = :covalent, bondwidth = 0.3)
    bshapes = Cylinder3{Float32}[]
	bnds = getbonds(chn, selectors...; algo = algo)
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