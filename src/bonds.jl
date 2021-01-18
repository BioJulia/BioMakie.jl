abstract type AbstractTether end
mutable struct Tether{T} <:AbstractTether where {T}
	points::T
end
mutable struct Bond <:AbstractTether
	points
	bondtype
end
mutable struct Residue{Symbol} <:AbstractResidue
	parent
	atoms
	bonds::Vector{Bond}
end
Bond(x1::StructuralElement, x2::StructuralElement) = Bond([x1,x2],"1")

atoms(bond::AbstractTether) = bond.points
points(tether::AbstractTether) = tether.points
function resbonds(res::AbstractResidue;
					hres = false)
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
			push!(missingbonds, [firstatomname, secondatomname])
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
				push!(missingbonds, [firstatomname, secondatomname])
			end
		end
		# for atmkey in atmkeys
		# 	if element(resatoms2[atmkey]) == "H"
		# 		foundbond = false
		# 		bondatms = []
		# 		for bond in bonds
		# 			push!(bondatms, atoms(bond))
		# 		end
		# 		if resatoms2[atmkey] in bondatms
		# 			foundbond = true
		# 		end
		# 		if foundbond == false
		# 			heavyatms = collectatoms(resatoms2, !hydrogenselector)
		# 			closestheavyatom = heavyatms[1]
		# 			for atm in heavyatms
		# 				if BioStructures.distance(resatoms2[atmkey], atm) < BioStructures.distance(closestheavyatom, atm)
		# 					closestheavyatom = atm
		# 				end
		# 			end
		# 			push!(bonds, Bond(closestheavyatom,resatoms2[atmkey]))
		# 		end
		# 	end
		# end
	end
	restype = res.name
	restype2 = Symbol("$(restype)")
	new_bonds = eval(Residue{restype2}(res,resatoms,bonds))
	return new_bonds
end
# function backbonebonds(chn::BioStructures.Chain)
# 	bbatoms = collectatoms(chn, fullbbselector)
# 	bbkeys = collect(keys(bbatoms))
# 	bonds = []
# 	for i = 1:(size(bbkeys,1)-1)
# 		firstatomname = bbkeys[i]
# 		secondatomname = bbkeys[i+1]
# 		println("$(bbkeys[i])")
# 		firstatomname == " N  " && secondatomname == " CA " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]))
# 		firstatomname == " CA " && secondatomname == " C  " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]))
# 		firstatomname == " C  " && secondatomname == " O  " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]),"1.5")
# 		secondatomname == " N  " && firstatomname == " C  " && push!(bonds, Bond(bbatoms[i], bbatoms[i+1]),"1.5")
# 		secondatomname == " N  " && "$(bbkeys[i-2])" ==  " C  " && push!(bonds, Bond(bbatoms[i+1], bbatoms[i-2]),"1.5")
# 	end
# 	return bonds
# end
# using GLMakie
# prot1 = viewstruc("2vb1")
# atms1 = collectatoms(chains(prot1)["A"], fullbbselector)
# backbonebonds(chains(prot1)["A"])
# resids(atms1)
#
# ch1 = chains(prot1)[([keys(prot1 |> chains)...][1])]
# for x in [([ch1...][1].atoms)...]
# 	println("$(x)")
# end
# [([ch1...][1].atoms)...]


function bondshape(twoatms::AbstractArray{T}) where {T<:AbstractAtom}
    pnt1 = GeometryBasics.Point3f0(coords(twoatms[1])[1], coords(twoatms[1])[2], coords(twoatms[1])[3])
    pnt2 = GeometryBasics.Point3f0(coords(twoatms[2])[1], coords(twoatms[2])[2], coords(twoatms[2])[3])
    cyl = GeometryBasics.Cylinder(pnt1,pnt2,Float32(0.15))
    return cyl
end
bondshape(bond::Bond) = bondshape(atoms(bond))
bondshape(bondlist::AbstractArray{Bond}) = bondshape.(bondlist)
bondshape(resbonds::Residue{Symbol}) = bondshape.(resbonds.bonds)
function collectbondshapes(arr)
	shapes = []
	for i = 1:size(arr,1)
		for j = 1:size(arr[i],1)
			push!(shapes,arr[i][j])
		end
	end
	return shapes |> Vector{GeometryBasics.Cylinder{3,Float32}}
end
