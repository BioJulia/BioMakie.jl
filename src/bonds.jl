# known bonds for residues #
heavyresbonds = Dict(
                "ARG" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD"],["CD","NE"],["NE","CZ"],["CZ","NH1"],["CZ","NH2"]],
                "MET" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","SD"],["SD","CE"]],
                "ASN" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","OD1"],["CG","ND2"]],
                "GLU" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD"],["CD","OE1"],["CD","OE2"]],
                "PHE" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD1"],["CG","CD1"],["CD1","CE1"],["CD2","CE2"],["CE1","CZ"],["CE2","CZ"]],
                "ILE" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG1"],["CB","CG2"],["CG1","CD1"]],
                "ASP" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","OD1"],["CG","OD2"]],
                "LEU" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD1"],["CG","CD2"]],
                "ALA" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"]],
                "GLN" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD"],["CD","OE1"],["CD","NE2"]],
                "GLY" => [["C","O"],["C","CA"],["CA","N"]],
                "CYS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","SG"]],
                "TRP" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD1"],["CG","CD2"],["CD1","NE1"],["CD2","CE2"],["CD2","CE3"],["CE2","CZ2"],["CE3","CZ3"],["CZ2","CH2"],["CZ3","CH2"]],
                "TYR" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD1"],["CG","CD2"],["CD1","CE1"],["CD2","CE2"],["CE1","CZ"],["CE2","CZ"]],
                "LYS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","CD"],["CD","CE"],["CE","NZ"]],
                "PRO" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["N","CD"],["CB","CG"],["CG","CD"]],
                "THR" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","OG1"],["CB","CG2"]],
                "SER" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","OG"]],
                "VAL" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG1"],["CB","CG2"]],
                "HIS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],["CG","ND1"],["CG","CD2"],["ND1","CE1"],["CD2","NE2"],["NE2","CE1"]]
)
hresbonds = Dict(
                "ARG" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CG","HG1"],["CG","HG2"],["CD","HD1"],["CD","HD2"],["NE","HE"],["NH1","HH11"],["NH1","HH12"],["NH2","HH21"],["NH2","HH22"]],
                "MET" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CG","HG1"],["CG","HG2"],["CE","HE1"],["CE","HE2"],["CE","HE3"]],
                "ASN" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["ND2","HD21"],["ND2","HD22"]],
                "GLU" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CG","HG1"],["CG","HG2"]],
                "PHE" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CD1","HD1"],["CD2","HD2"],["CE1","HE1"],["CE2","HE2"],["CZ","HZ"]],
                "ILE" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB"],["CG1","HG11"],["CG1","HG12"],["CG2","HG21"],["CG2","HG22"],["CG","HG23"],["CD1","HD11"],["CD1","HD12"],["CD1","HD13"]],
                "ASP" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"]],
                "LEU" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CG","HG"],["CD1","HD11"],["CD1","HD12"],["CD1","HD13"],["CD2","HD21"],["CD2","HD22"],["CD2","HD23"]],
                "ALA" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CB","HB3"]],
                "GLN" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CG","HG1"],["CG","HG2"],["NE2","HE21"],["NE2","HE22"]],
                "GLY" => [["N","HN1"],["N","HN2"],["CA","HA1"],["CA","HA2"]],
                "CYS" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["SG","HG"]],
                "TRP" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CD1","HD1"],["NE1","HE1"],["CE3","HE3"],["CZ2","HZ2"],["CH2","HH2"],["CZ3","HZ3"]],
                "TYR" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CD1","HD1"],["CD2","HD2"],["CE1","HE1"],["CE2","HE2"],["OH","HH"]],
                "LYS" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CG","HG1"],["CG","HG2"],["CD","HD1"],["CD","HD2"],["CE","HE1"],["CE","HE2"],["NZ","HZ1"],["NZ","HZ2"]],
                "PRO" => [["N","HN"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CG","HG1"],["CG","HG2"],["CD","HD1"],["CD","HD2"]],
                "THR" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB"],["OG1","HG1"],["CG2","HG21"],["CG2","HG22"],["CG2","HG23"]],
                "SER" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["OG","HG"]],
                "VAL" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB"],["CG1","HG11"],["CG1","HG12"],["CG1","HG13"],["CG2","HG21"],["CG2","HG22"],["CG2","HG23"]],
                "HIS" => [["N","HN1"],["N","HN2"],["CA","HA"],["CB","HB1"],["CB","HB2"],["ND1","HD1"],["CD2","HD2"],["CE1","HE1"]],
)
# nonbonds = Dict(
#                 "ARG" => [["OXT"]],
#                 "MET" => [["OXT","HXT"]],
#                 "ASN" => [["OXT","HXT"]],
#                 "GLU" => [["OXT","HXT"]],
#                 "PHE" => [["OXT","HXT"]],
#                 "ILE" => [["OXT","HXT"]],
#                 "ASP" => [["OXT","HXT"]],
#                 "LEU" => [["OXT","HXT"]],
#                 "ALA" => [["OXT","HXT"]],
#                 "GLN" => [["OXT","HXT"]],
#                 "GLY" => [["OXT","HXT"]],
#                 "CYS" => [["OXT","HXT"]],
#                 "TRP" => [["OXT","HXT"]],
#                 "TYR" => [["OXT","HXT"]],
#                 "LYS" => [["OXT","HXT"]],
#                 "PRO" => [["OXT","HXT"]],
#                 "THR" => [["OXT","HXT"]],
#                 "SER" => [["OXT","HXT"]],
#                 "VAL" => [["OXT","HXT"]],
#                 "HIS" => [["OXT","HXT"]],
# )

mutable struct Tether{T} <:AbstractTether where {T<:StructuralElementOrList}
	points::T
end
mutable struct Bond <:AbstractTether
	points::StructuralElementOrList
end
# mutable struct ResBonds2
# 	parent
# 	atoms::Vector{AbstractAtom}
# 	bonds::Vector{Bond}
# 	missingbonds::Vector{Bond}
# 	extrabonds::Vector{Bond}
# end
mutable struct ResBonds
	parent
	atoms::Union{AbstractDict,AbstractArray}
	bonds::Vector{Bond}
	missingbonds::Vector{Bond}
	extrabonds::Vector{Bond}
end
Bond(x1::StructuralElement, x2::StructuralElement) = Bond([x1,x2])
atoms(bond::Bond) = bond.points
points(tether::AbstractTether) = tether.points

function bonds(res::AbstractResidue; hres = false)
	bonds = []
	missingbonds = []
	resatoms = res.atoms
	resatomkeys = _stripkeys(resatoms)

	for heavybond in heavyresbonds[res.name]
		firstatomname = "$(heavybond[1])"
		secondatomname = "$(heavybond[2])"
		if heavybond[1] in resatomkeys && heavybond[2] in resatomkeys
			if length(heavybond[1]) == 1
				firstatomname = " $(heavybond[1])  "
			elseif length(heavybond[1]) == 2
				firstatomname = " $(heavybond[1]) "
			elseif length(heavybond[1]) == 3
				firstatomname = " $(heavybond[1])"
			else
				println("unusual atom $(heavybond[1])")
			end
			if length(heavybond[2]) == 1
				secondatomname = " $(heavybond[2])  "
			elseif length(heavybond[2]) == 2
				secondatomname = " $(heavybond[2]) "
			elseif length(heavybond[2]) == 3
				secondatomname = " $(heavybond[2])"
			else
				println("unusual atom $(heavybond[2])")
			end
			push!(bonds, Bond(resatoms[firstatomname], resatoms[secondatomname]))
		else
			push!(missingbonds, Bond(resatoms[firstatomname], resatoms[secondatomname]))
		end
	end
	if hres == true
		for hresbond in hresbonds[res.name]
			firstatomname = "$(hresbond[1])"
			secondatomname = "$(hresbond[2])"
			if hresbond[1] in resatomkeys && hresbond[2] in resatomkeys
				if length(hresbond[1]) == 1
					firstatomname = " $(hresbond[1])  "
				elseif length(hresbond[1]) == 2
					firstatomname = " $(hresbond[1]) "
				elseif length(hresbond[1]) == 3
					firstatomname = " $(hresbond[1])"
				else
					println("unusual atom $(hresbond[1])")
				end
				if length(hresbond[2]) == 1
					secondatomname = " $(hresbond[2])  "
				elseif length(hresbond[2]) == 2
					secondatomname = " $(hresbond[2]) "
				elseif length(hresbond[2]) == 3
					secondatomname = " $(hresbond[2])"
				else
					println("unusual atom $(hresbond[2])")
				end
				push!(bonds, Bond(resatoms[firstatomname], resatoms[secondatomname]))
			else
				push!(missingbonds, Bond(resatoms[firstatomname], resatoms[secondatomname]))
			end
		end
	end
	new_bonds = ResBonds(res,resatoms,bonds,missingbonds,[])
	return new_bonds
end

# bonds(residues[][1])
