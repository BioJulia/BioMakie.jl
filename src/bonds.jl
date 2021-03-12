abstract type AbstractTether end
mutable struct Tether{T} <:AbstractTether where {T}
	points::T
end
points(tether::AbstractTether) = tether.points
mutable struct Bond <:AbstractTether
	atoms
	bondtype
end
Bond(atom1::AbstractAtom, atom2::AbstractAtom) = Bond([atom1,atom2],"1")
atoms(bond::AbstractTether) = bond.atoms
bonds(residues) = resbonds.(residues; hres = true)
bondshapes(bonds) = bondshape.(bonds)
function resbonds(	res::AbstractResidue;
					hres = false,
					showmissing = false)
	bonds = []
	missingbonds = []
	resatoms = res.atoms
	resatoms2 = collectatoms(res)
	atmkeys = keys(resatoms2) |> collect
	resatomkeys = _stripkeys(resatoms)
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
			push!(bonds, Bond(resatoms[firstatomname], resatoms[secondatomname]))
		else
			if showmissing == true
				print("| $(firstatomname) $(secondatomname) bond missing |")
			end
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
				push!(bonds, Bond(resatoms[firstatomname], resatoms[secondatomname]))
			else
				if showmissing == true
					print("| $(firstatomname) $(secondatomname) bond missing |")
				end
			end
		end
	end
	return bonds |> Array{Bond}
end
function backbonebonds(chn::BioStructures.Chain)
	bbatoms = collectatoms(chn, backboneselector)
	bbkeys = collect(keys(bbatoms))
	bonds = []
	for i = 1:(size(bbkeys,1)-1)
		firstatomname = bbkeys[i]
		secondatomname = bbkeys[i+1]
		# println("$(bbkeys[i])")
		firstatomname == " N  " && secondatomname == " CA " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]))
		firstatomname == " CA " && secondatomname == " C  " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]))
		firstatomname == " C  " && secondatomname == " O  " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]),"1.5")
		secondatomname == " N  " && firstatomname == " C  " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]),"1.5")
		secondatomname == " N  " && "$(bbkeys[i-2])" ==  " C  " && push!(bonds, Bond(bbatoms[i+1], bbatoms[i-2]),"1.5")
	end
	return bonds
end
function bondshape(twoatms::AbstractArray{T}) where {T<:AbstractAtom}
    pnt1 = GeometryBasics.Point3f0(coords(twoatms[1])[1], coords(twoatms[1])[2], coords(twoatms[1])[3])
    pnt2 = GeometryBasics.Point3f0(coords(twoatms[2])[1], coords(twoatms[2])[2], coords(twoatms[2])[3])
    cyl = GeometryBasics.Cylinder(pnt1,pnt2,Float32(0.15))
    return cyl
end
bondshape(bond::Bond) = bondshape(atoms(bond))
bondshape(resbonds::AbstractArray{Bond}) = bondshape.(bondlist)
function collectbondshapes(arr)
	shapes = []
	for i = 1:size(arr,1)
		for j = 1:size(arr[i],1)
			push!(shapes,arr[i][j])
		end
	end
	return shapes |> Vector{GeometryBasics.Cylinder{3,Float32}}
end
