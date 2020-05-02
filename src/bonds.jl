heavyresbonds = Dict(
                "ARG" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","NE"],["NE","CZ"],["CZ","NH1"],["CZ","NH2"]],
                "MET" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","SD"],["SD","CE"]],
                "ASN" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","OD1"],["CG","ND2"]],
                "GLU" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","OE1"],["CD","OE2"]],
                "PHE" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD1"],["CD1","CE1"],["CD2","CE2"],["CE1","CZ"],["CE2","CZ"]],
                "ILE" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG1"],
						["CB","CG2"],["CG1","CD1"]],
                "ASP" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","OD1"],["CG","OD2"]],
                "LEU" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD2"]],
                "ALA" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"]],
                "GLN" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","OE1"],["CD","NE2"]],
                "GLY" => [["C","O"],["C","CA"],["CA","N"]],
                "CYS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","SG"]],
                "TRP" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD2"],["CD1","NE1"],["CD2","CE2"],["CD2","CE3"],
						["CE2","CZ2"],["CE3","CZ3"],["CZ2","CH2"],["CZ3","CH2"]],
                "TYR" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD2"],["CD1","CE1"],["CD2","CE2"],["CE1","CZ"],
						["CE2","CZ"],["CZ","OH"]],
                "LYS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","CE"],["CE","NZ"]],
                "PRO" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["N","CD"],["CB","CG"],["CG","CD"]],
                "THR" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","OG1"],["CB","CG2"]],
                "SER" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","OG"]],
                "VAL" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG1"],["CB","CG2"]],
                "HIS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","ND1"],["CG","CD2"],["ND1","CE1"],["CD2","NE2"],["NE2","CE1"]]
)
hresbonds = Dict(
                "ARG" => [["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG1"],["CG","HG2"],["CD","HD1"],["CD","HD2"],["NE","HE"],
						["NH1","HH11"],["NH1","HH12"],["NH2","HH21"],["NH2","HH22"]],
                "MET" => [["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG1"],["CG","HG2"],["CE","HE1"],["CE","HE2"],["CE","HE3"]],
                "ASN" => [["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["ND2","HD21"],["ND2","HD22"]],
                "GLU" => [["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG3"],["CG","HG2"]],
                "PHE" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CD1","HD1"],
						["CD2","HD2"],["CE1","HE1"],["CE2","HE2"],["CZ","HZ"]],
                "ILE" => [["N","H"],["CA","HA"],["CB","HB"],["CG1","HG11"],["CG1","HG12"],
						["CG2","HG21"],["CG2","HG22"],["CG2","HG23"],["CD1","HD11"],["CD1","HD12"],["CD1","HD13"]],
                "ASP" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"]],
                "LEU" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CG","HG"],
						["CG1","HG1"],["CD1","HD11"],["CD1","HD12"],["CD1","HD13"],
						["CD2","HD21"],["CD2","HD22"],["CD2","HD23"]],
                "ALA" => [["N","H"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CB","HB3"]],
                "GLN" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CG","HG1"],
						["CG","HG2"],["NE2","HE21"],["NE2","HE22"]],
                "GLY" => [["N","H"],["CA","HA2"],["CA","HA3"]],
                "CYS" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["SG","HG"]],
                "TRP" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CD1","HD1"],
						["NE1","HE1"],["CE3","HE3"],["CZ2","HZ2"],["CH2","HH2"],["CZ3","HZ3"]],
                "TYR" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CD1","HD1"],
						["CD2","HD2"],["CE1","HE1"],["CE2","HE2"],["OH","HH"]],
                "LYS" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CG","HG3"],
						["CG","HG2"],["CD","HD3"],["CD","HD2"],["CE","HE3"],["CE","HE2"],["NZ","HZ1"],["NZ","HZ2"],["NZ","HZ3"]],
                "PRO" => [["N","H"],["N","HN"],["CA","HA"],["CB","HB1"],["CB","HB2"],
						["CG","HG1"],["CG","HG2"],["CD","HD1"],["CD","HD2"]],
                "THR" => [["N","H"],["CA","HA"],["CB","HB"],["OG1","HG1"],["CG2","HG21"],
						["CG2","HG22"],["CG2","HG23"]],
                "SER" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["OG","HG"]],
                "VAL" => [["N","H"],["CA","HA"],["CB","HB"],["CG1","HG11"],["CG1","HG12"],
						["CG1","HG13"],["CG2","HG21"],["CG2","HG22"],["CG2","HG23"]],
                "HIS" => [["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["ND1","HD1"],
						["CD2","HD2"],["CE1","HE1"]],
)
mutable struct Tether{T} <:AbstractTether where {T<:StructuralElementOrList}
	points::T
end
mutable struct Bond <:AbstractBond
	points::StructuralElementOrList
end
mutable struct ResBonds{R} <:AbstractResidue where {R<:Symbol}
	parent
	atoms::Union{AbstractDict,AbstractArray}
	bonds::Vector{Bond}
	missingbonds::Vector{Union{Bond,AbstractArray}}
	extrabonds::Vector{Bond}
end
Bond(x1::StructuralElement, x2::StructuralElement) = Bond([x1,x2])
atoms(bond::Bond) = bond.points
points(tether::AbstractTether) = tether.points
function resbonds(res::AbstractResidue; hres = false)
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
	restype = Symbol("$(restype)")
	new_bonds = eval(ResBonds{restype}(res,resatoms,bonds,missingbonds,[]))
	return new_bonds
end
function bondshape(twoatms::AbstractArray{T}) where {T<:AbstractAtom}
    pnt1 = GeometryBasics.Point3f0(coords(twoatms[1])[1], coords(twoatms[1])[2], coords(twoatms[1])[3])
    pnt2 = GeometryBasics.Point3f0(coords(twoatms[2])[1], coords(twoatms[2])[2], coords(twoatms[2])[3])
    cyl = GeometryBasics.Cylinder(pnt1,pnt2,Float32(0.15))
    return cyl
end
bondshape(bond::AbstractBond) = bondshape(atoms(bond))
bondshape(bondlist::AbstractArray{Bond}) = bondshape.(bondlist)
bondshape(resbonds::ResBonds) = bondshape.(resbonds.bonds)
function collectbondshapes(arr)
	shapes = []
	for i = 1:size(arr,1)
		for j = 1:size(arr[i],1)
			push!(shapes,arr[i][j])
		end
	end
	return shapes |> Vector{GeometryBasics.Cylinder{3,Float32}}
end
