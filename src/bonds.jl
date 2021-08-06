export  AtomBond,
		resbonds,
		backbonebonds,
		bonds,
		bondshape

abstract type AbstractTether end
abstract type AbstractBond <: AbstractTether end
mutable struct AtomBond{T} <:Bond where {T}
	atoms::Vector{T}
end
import BioStructures.defaultatom, BioStructures.defaultresidue
defaultatom(at::BioStructures.Atom) = at
defaultresidue(res::BioStructures.Residue) = res
convert(::BioStructures.Atom,disat::DisorderedAtom) = defaultatom(disat)
AtomBond(atom1::AbstractAtom, atom2::AbstractAtom) = AtomBond([atom1,atom2])
atoms(bond::AtomBond) = bond.atoms
function resbonds(	res::AbstractResidue,
					selectors::Function...;
					hres = true)
	bonds = Vector{AtomBond}()
	resatoms = res.atoms
	# resatoms2 = collectatoms(res,selectors...) .|> defaultatom
	# atmkeys = keys(resatoms) |> collect
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
			push!(bonds, AtomBond(resatoms[firstatomname], resatoms[secondatomname]))
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
				push!(bonds, AtomBond(resatoms[firstatomname], resatoms[secondatomname]))
			end
		end
	end
	return bonds
end
function backbonebonds(chn::BioStructures.Chain)
	bbatoms = collectatoms(chn, backboneselector) .|> defaultatom
	bonds = Vector{AtomBond}()
	for i = 1:(size(bbatoms,1)-1)
		firstatomname = bbatoms[i].name
		secondatomname = bbatoms[i+1].name
		firstatomname == " N  " && secondatomname == " CA " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < 1.8 && push!(bonds, AtomBond(bbatoms[i], bbatoms[i+1]))
		firstatomname == " CA " && secondatomname == " C  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < 1.8 && push!(bonds, AtomBond(bbatoms[i], bbatoms[i+1]))
		firstatomname == " C  " && secondatomname == " O  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i+1])) < 1.8 && push!(bonds, AtomBond(bbatoms[i], bbatoms[i+1]))
		try
			firstatomname == " N  " && bbatoms[i-2].name ==  " C  " && euclidean(atomcoords(bbatoms[i]), atomcoords(bbatoms[i-2])) < 1.8 && push!(bonds, AtomBond(bbatoms[i], bbatoms[i-2]))
		catch

		end
	end

	return bonds
end
bonds(residues::AbstractArray{AbstractResidue}, selectors::Function...; hres = true) = resbonds.(residues; hres = hres)
function bonds(chain::BioStructures.Chain, selectors::Function...; hres = true)
	rbonds = bonds(collectresidues(chain, selectors...); hres = hres) |> SplitApplyCombine.flatten
	bbonds = backbonebonds(chain)
	chbonds = vcat(rbonds,bbonds)
	return chbonds
end
function bondshape(bond::AtomBond)
	twoatms = atoms(bond)
    pnt1 = GeometryBasics.Point3f0(coords(twoatms[1])[1], coords(twoatms[1])[2], coords(twoatms[1])[3])
    pnt2 = GeometryBasics.Point3f0(coords(twoatms[2])[1], coords(twoatms[2])[2], coords(twoatms[2])[3])
    cyl = GeometryBasics.Cylinder(pnt1,pnt2,Float32(0.15))
    return cyl
end
function bondshape(bonds::AbstractArray{T}) where {T<:AtomBond}
	return bondshape.(bonds)
end
