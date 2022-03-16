
function resbonds(res::BioStructures.AbstractResidue; hres = true)
	bonds = []
	resatoms = res.atoms
	resatomkeys = stripkeys(resatoms)
	for heavybond in heavyresbonds[res.name]
		firstatomname = "$(heavybond[1])"
		secondatomname = "$(heavybond[2])"
		if firstatomname in resatomkeys && secondatomname in resatomkeys
			if length(heavybond[1]) == 1
				firstatomname = " $(heavybond[1])  "
			elseif length(heavybond[1]) == 2
				firstatomname = " $(heavybond[1]) "
			elseif length(heavybond[1]) == 3
				firstatomname = " $(heavybond[1])"
			elseif length(heavybond[1]) == 4
				firstatomname = "$(heavybond[1])"
			else
				println("unusual atom $(heavybond[1])")
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
				println("unusual atom $(heavybond[2])")
			end
			push!(bonds, (resatoms[firstatomname], resatoms[secondatomname]))
		end
	end
	if hres == true
		for hresbond in hresbonds[res.name]
			firstatomname = "$(hresbond[1])"
			secondatomname = "$(hresbond[2])"
			if firstatomname in resatomkeys && secondatomname in resatomkeys
				if length(hresbond[1]) == 1
					firstatomname = " $(hresbond[1])  "
				elseif length(hresbond[1]) == 2
					firstatomname = " $(hresbond[1]) "
				elseif length(hresbond[1]) == 3
					firstatomname = " $(hresbond[1])"
				elseif length(hresbond[1]) == 4
					firstatomname = "$(hresbond[1])"
				else
					println("unusual atom $(hresbond[1])")
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
					println("unusual atom $(hresbond[2])")
				end
				push!(bonds, (resatoms[firstatomname], resatoms[secondatomname]))
			end
		end
	end
	return bonds
end

function backbonebonds(chn::BioStructures.Chain)
	bbatoms = collectatoms(chn, backboneselector) .|> defaultatom
	bonds = []

	for i = 1:(size(bbatoms,1)-1)
		firstatomname = bbatoms[i].name
		secondatomname = bbatoms[i+1].name
		firstatomname == " N  " && secondatomname == " CA " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < 1.8 && push!(bonds, (bbatoms[i], bbatoms[i+1]))
		firstatomname == " CA " && secondatomname == " C  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < 1.8 && push!(bonds, (bbatoms[i], bbatoms[i+1]))
		firstatomname == " C  " && secondatomname == " O  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < 1.8 && push!(bonds, (bbatoms[i], bbatoms[i+1]))
		try
			firstatomname == " N  " && bbatoms[i-2].name ==  " C  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i-2])) < 1.8 && push!(bonds, (bbatoms[i], bbatoms[i-2]))
		catch
			println("error with backbone bonds")
		end
	end

	return bonds
end

function getbonds(residues::AbstractArray{T}; kwargs...) where {T<:BioStructures.AbstractResidue}
	return resbonds.(residues; kwargs...)
end

function getbonds(chn::BioStructures.Chain)
	rbonds = getbonds(collectresidues(chn,standardselector)) |> SplitApplyCombine.flatten
	bbonds = backbonebonds(chn)
	chbonds = vcat(rbonds,bbonds)
	return chbonds
end

# Default bond shape is a cylinder mesh. TODO: maybe add double and triple bond shapes.
function bondshape(twoatoms::AbstractArray{T}; bondwidth = 0.15) where {T<:BioStructures.AbstractAtom}
    @assert length(twoatoms) == 2
	pnt1 = GeometryBasics.Point3f0(twoatoms[1].coords)
    pnt2 = GeometryBasics.Point3f0(twoatoms[2].coords)
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end

function bondshape(twopnts::AbstractArray{AbstractVector{T}}; bondwidth = 0.15) where {T<:AbstractFloat}
    @assert length(twopnts) == 2
	pnt1 = GeometryBasics.Point3f0(twopnts[1])
    pnt2 = GeometryBasics.Point3f0(twopnts[2])
    return GeometryBasics.Cylinder(pnt1,pnt2,Float32(bondwidth))
end

function bondshape(twopnts::AbstractMatrix{T}; bondwidth = 0.15) where {T<:AbstractFloat}
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
