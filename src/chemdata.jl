export atomicmasses,
	   covalentradii,
	   vanderwaalsradii
	   

using MolecularGraph: ATOMTABLE, ATOMSYMBOLMAP, ATOM_COVALENT_RADII, ATOM_VANDERWAALS_RADII

ATOMSYMBOLKEYS = keys(ATOMSYMBOLMAP) |> collect
atomicmasses = Dict{String,Float32}(ATOMSYMBOLKEYS.=>[ATOMTABLE[ATOMSYMBOLMAP[x]]["Weight"] for x in ATOMSYMBOLKEYS])

# Collection of radii using MolecularGraph.jl constants.
# Covalent radii
_covrad = []
for x in ATOMSYMBOLKEYS
	try
		push!(_covrad,Dict{String,Float32}(x=>ATOM_COVALENT_RADII[ATOMTABLE[ATOMSYMBOLMAP[x]]["Number"]]))
	catch

	end
	push!(_covrad,Dict{String,Float32}("Csp2" => 0.73, "Csp3" => 0.76, "Csp" => 0.69, "C" => 0.76))
	push!(_covrad,Dict{String,Float32}("Mn h.s." => 1.61, "Mn l.s." => 1.39))
	push!(_covrad,Dict{String,Float32}("Fe h.s." => 1.52, "Fe l.s." => 1.32))
	push!(_covrad,Dict{String,Float32}("Co h.s." => 1.5, "Co l.s." => 1.26))
end
covalentradii = merge(_covrad...)

# VanderWaals radii
_vdwrad = []
for x in ATOMSYMBOLKEYS
	try
		push!(_vdwrad,Dict{String,Float32}(x=>ATOM_VANDERWAALS_RADII[ATOMTABLE[ATOMSYMBOLMAP[x]]["Number"]]))
	catch
		# println("error involving vanderwaals radii")
	end
end
vanderwaalsradii = merge(_vdwrad...)

# Collection of known heavy bonds, for a PDB structure file. Note only the 20 amino acids have knowledge-based bonds defined here so far.
heavyresbonds = Dict(
                "ARG" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","NE"],["NE","CZ"],["CZ","NH1"],["CZ","NH2"],["C","OXT"]],
                "MET" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","SD"],["SD","CE"],["C","OXT"]],
                "ASN" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","OD1"],["CG","ND2"],["C","OXT"]],
                "GLU" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","OE1"],["CD","OE2"],["C","OXT"]],
                "PHE" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD1"],["CD1","CE1"],["CD2","CE2"],["CE1","CZ"],["CE2","CZ"],["C","OXT"]],
                "ILE" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG1"],
						["CB","CG2"],["CG1","CD1"],["C","OXT"]],
                "ASP" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","OD1"],["CG","OD2"],["C","OXT"]],
                "LEU" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD2"],["C","OXT"]],
                "ALA" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["C","OXT"]],
                "GLN" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","OE1"],["CD","NE2"],["C","OXT"]],
                "GLY" => [["C","O"],["C","CA"],["CA","N"],["C","OXT"]],
                "CYS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","SG"],["C","OXT"]],
                "TRP" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD2"],["CD1","NE1"],["CE2","NE1"],["CD2","CE2"],["CD2","CE3"],
						["CE2","CZ2"],["CE3","CZ3"],["CZ2","CH2"],["CZ3","CH2"],["C","OXT"]],
                "TYR" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD1"],["CG","CD2"],["CD1","CE1"],["CD2","CE2"],["CE1","CZ"],
						["CE2","CZ"],["CZ","OH"],["C","OXT"]],
                "LYS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","CD"],["CD","CE"],["CE","NZ"],["C","OXT"]],
                "PRO" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["N","CD"],["CB","CG"],["CG","CD"],["C","OXT"]],
                "THR" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","OG1"],["CB","CG2"],["C","OXT"]],
                "SER" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","OG"],["C","OXT"]],
				"VAL" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG1"],["CB","CG2"],["C","OXT"]],
				"NAG" => [],
				"HOH" => [],
                "HIS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","ND1"],["CG","CD2"],["ND1","CE1"],["CD2","NE2"],["NE2","CE1"],["C","OXT"]],
				" ZN" => []
)
# Collection of known hydrogen covalent bonds, for a PDB structure file. Note only the 20 amino acids have knowledge-based bonds defined here so far.
hresbonds = Dict(
                "ARG" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG2"],["CG","HG3"],["CD","HD2"],["CD","HD3"],["NE","HE"],
						["NH1","HH11"],["NH1","HH12"],["NH2","HH21"],["NH2","HH22"]],
                "MET" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG1"],["CG","HG2"],["CE","HE1"],["CE","HE2"],["CE","HE3"]],
                "ASN" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["ND2","HD21"],["ND2","HD22"]],
                "GLU" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG3"],["CG","HG2"]],
                "PHE" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CD1","HD1"],
						["CD2","HD2"],["CE1","HE1"],["CE2","HE2"],["CZ","HZ"]],
                "ILE" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB"],["CG1","HG13"],["CG1","HG12"],
						["CG2","HG21"],["CG2","HG22"],["CG2","HG23"],["CD1","HD11"],["CD1","HD12"],["CD1","HD13"]],
                "ASP" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["OD2","HD2"]],
                "LEU" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CG","HG"],
						["CG1","HG1"],["CD1","HD11"],["CD1","HD12"],["CD1","HD13"],
						["CD2","HD21"],["CD2","HD22"],["CD2","HD23"]],
                "ALA" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB1"],["CB","HB2"],["CB","HB3"]],
                "GLN" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CG","HG3"],
						["CG","HG2"],["NE2","HE21"],["NE2","HE22"]],
                "GLY" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA2"],["CA","HA3"]],
                "CYS" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["SG","HG"]],
                "TRP" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CD1","HD1"],
						["NE1","HE1"],["CE3","HE3"],["CZ2","HZ2"],["CH2","HH2"],["CZ3","HZ3"]],
                "TYR" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CD1","HD1"],
						["CD2","HD2"],["CE1","HE1"],["CE2","HE2"],["OH","HH"]],
                "LYS" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["CG","HG3"],
						["CG","HG2"],["CD","HD3"],["CD","HD2"],["CE","HE3"],["CE","HE2"],["NZ","HZ1"],["NZ","HZ2"],["NZ","HZ3"]],
                "PRO" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["N","HN"],["CA","HA"],["CB","HB2"],["CB","HB3"],
						["CG","HG2"],["CG","HG3"],["CD","HD2"],["CD","HD3"]],
                "THR" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB"],["OG1","HG1"],["CG2","HG21"],
						["CG2","HG22"],["CG2","HG23"]],
                "SER" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["OG","HG"]],
                "VAL" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB"],["CG1","HG11"],["CG1","HG12"],
						["CG1","HG13"],["CG2","HG21"],["CG2","HG22"],["CG2","HG23"]],
                "HIS" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CB","HB3"],["CB","HB2"],["ND1","HD1"],
						["CD2","HD2"],["CE1","HE1"]],
				"NAG" => [],
				"HOH" => [],
				" ZN" => []
)
