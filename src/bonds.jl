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

mutable struct Tether{T} <:AbstractTether where {T<:StructuralElementOrList}
	points::T
end
mutable struct Bond <:AbstractBond
	points::StructuralElementOrList
end
mutable struct ResBonds
	parent
	atoms::Union{AbstractDict,AbstractArray}
	bonds::Vector{Bond}
	missingbonds::Vector{Union{Bond,AbstractArray}}
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
		if firstatomname in resatomkeys && secondatomname in resatomkeys
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
				push!(missingbonds, [firstatomname, secondatomname])
			end
		end
	end
	new_bonds = ResBonds(res,resatoms,bonds,missingbonds,[])
	return new_bonds
end
function bondshape(twoatms::AbstractArray{T}) where {T<:AbstractAtom}
    pnt1 = Point3f0(coords(twoatms[1])[1], coords(twoatms[1])[2], coords(twoatms[1])[3])
    pnt2 = Point3f0(coords(twoatms[2])[1], coords(twoatms[2])[2], coords(twoatms[2])[3])
    cyl = GeometryTypes.Cylinder(pnt1,pnt2,Float32(0.15))
    # cylresolution = 10
    # vertices = decompose(Point3f0, cyl, cylresolution)
    # faces = decompose(Face{3, Int}, cyl, cylresolution)
    # coordinates = [vertices[i][j] for i = 1:length(vertices), j = 1:3]
    # connectivity = [faces[i][j] for i = 1:length(faces), j = 1:3]
    return cyl #[Float32.(coordinates), Int64.(connectivity)]
end
bondshape(bond::AbstractBond) = bondshape(atoms(bond))
bondshape(bondlist::AbstractArray{Bond,1}) = bondshape.(bondlist)
bondshape(resbonds::ResBonds) = bondshape.(resbonds.bonds)

allresbonds = bonds.(residues[])
bondshapes = bondshape.([allresbonds[i].bonds for i = 1:size(allresbonds,1)])

function collectbondshapes(arr::AbstractArray)
	shapes = []
	for i = 1:size(arr,1)
		for j = 1:size(arr[i],1)
			push!(shapes,arr[i][j])
		end
	end
	return shapes
end
shapes = collectbondshapes(bondshapes) |> Vector{Cylinder{3,Float32}}

# function bondmesh(res::AbstractResidue)
# 	resbonds = bonds(res)
# 	bondshapes = bondshape.(resbonds.bonds)
# 	shapes =
# 	return bondshapes
# end
# bondmesh(residues[][1])
# function allbondmesh(residues::AbstractArray{AbstractResidue})
# 	allcoords = []
# 	allconnects = []
# 	allresbonds = bonds.(residues)
# 	bondshapes = bondshape.([allresbonds[i].bonds for i = 1:size(allresbonds,1)])
# 	for i in 1:size(bondshapes,1)
# 		for j in 1:size(bondshapes[i],1)
# 			push!(allcoords, bondshapes[i][j][1])
# 			push!(allconnects, bondshapes[i][j][2])
# 		end
# 	end
# 	allcoords2 = []
# 	allconnects2 = []
# 	for k = 1:size(allcoords,1)
# 		for g in 1:size(allcoords[k],1)
# 			push!(allcoords2,allcoords[k][g,1:3])
# 		end
# 		for h in 1:size(allconnects[k],1)
# 			push!(allconnects2,.+(allconnects[k][h,1:3],(k-1)*12))
# 		end
# 	end
# 	return allcoords2 |> _g, allconnects2 |> _g
# end

scene, layout = layoutscene(resolution = (700,700))
sc_mol = layout[1:3,1:3] = LScene(scene)

meshscatter!(sc_scene, atmcoords, markersize = atmradii[]./4, color = atmcolors, show_axis = false)

# in this block, I have some problems
mesh!(shapes[1], color = Makie.RGBAf0(0.5,0.5,0.5,0.0)) # for some reason the first mesh I plot always has a weird plane connected to it, so I make this invisible
for i = 1:size(shapes,1)
	mesh!(sc_scene, shapes[i], color = Makie.RGBAf0(0.5,0.5,0.5,0.8)) # can this mesh loop be merged into a single mesh?
end

scene
