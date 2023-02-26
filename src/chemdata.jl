using MolecularGraph: ATOMTABLE, ATOMSYMBOLMAP, ATOM_COVALENT_RADII, ATOM_VANDERWAALS_RADII

ATOMSYMBOLKEYS = keys(ATOMSYMBOLMAP) |> collect
atomicmasses = Dict{String,Float32}(ATOMSYMBOLKEYS.=>[ATOMTABLE[ATOMSYMBOLMAP[x]]["Weight"] for x in ATOMSYMBOLKEYS])

# Collection of radii using MolecularGraph.jl constants.
# Covalent radii
_covrad = []
for x in ATOMSYMBOLKEYS
	try
		(push!(_covrad,Dict{String,Float32}(x=>ATOM_COVALENT_RADII[ATOMTABLE[ATOMSYMBOLMAP[x]]["Number"]])))
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
		(push!(_vdwrad,Dict{String,Float32}(x=>ATOM_VANDERWAALS_RADII[ATOMTABLE[ATOMSYMBOLMAP[x]]["Number"]])))
	catch
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
						["CG","CD1"],["CG","CD1"],["CG","CD2"],["CD1","CE1"],["CD2","CE2"],["CE1","CZ"],["CE2","CZ"],["C","OXT"]],
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
                "HIS" => [["C","O"],["C","CA"],["CA","N"],["CA","CB"],["CB","CG"],
						["CG","ND1"],["CG","CD2"],["ND1","CE1"],["CD2","NE2"],["NE2","CE1"],["C","OXT"]],
				"NAG" => [["C1", "O1"], ["C1", "C2"], ["C2", "C3"], ["C3", "C4"],
						["C3", "O3"], ["C4", "C5"], ["C5", "O5"], ["C5", "C6"],
						["C6", "O6"], ["C6", "C1"], ["C2", "N1"], ["N1", "C8"],
						["C8", "C7"], ["C7", "C6"], ["O3", "C1"], ["O5", "C5"],
						["O6", "C3"], ["O1", "C1"]],
				# "HOH" => [[]],
				# " ZN" => [[]],
				"ACT" => [["CH3","C"],["C","O"],["C","OXT"]],
				"NO3" => [["N","O1"],["N","O2"],["N","O3"]],
				"EDO" => [["C1","O1"],["C1","C2"],["C2","O2"]],
				"V8M" => [["N24","C25"],["N24","C23"],["C04","C05"],["C04","C03"],["C28","C27"],["C28","C29"],
						["C13","C14"],["C13","C12"],["C09","C08"],["C09","C10"],["O26","C25"],
						["O26","C27"],["O21","C20"],["O21","C22"],["C10","C11"],["C08","C07"],["C19","C20"],["N14","C14"],
						["C03","C02"],["N06","C06"],["C18","C17"],["C11","C12"],["C22","C23"],
						["O25","C24"],["O01","C01"],["C15","C16"],["C02","C01"],
						["C23","C24"],["C12","C13"],["O17","C16"],["N16","C15"],["C07","C06"],["C05","C06"],
						["C27","C26"],["S20","C19"]]
)

# Collection of known hydrogen covalent bonds, for a PDB structure file. Note only the 20 amino acids have knowledge-based bonds defined here so far.
hresbonds = Dict(
                "ARG" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG2"],["CG","HG3"],["CD","HD2"],["CD","HD3"],["NE","HE"],
						["NH1","HH11"],["NH1","HH12"],["NH2","HH21"],["NH2","HH22"]],
                "MET" => [["N","H1"],["N","H2"],["N","H3"],["N","H"],["CA","HA"],["CA","HA2"],["CB","HB3"],["CB","HB2"],
						["CG","HG1"],["CG","HG2"],["CG","HG3"],["CE","HE1"],["CE","HE2"],["CE","HE3"]],
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
				"NAG" => [["O1", "H1"], ["O3", "HO3"], ["O4", "HO4"], ["O5", "HO5"], ["O6", "HO6"], ["C2", "H2"],
						["C3", "H3"], ["C4", "H4"], ["C5", "H5"], ["C6", "H61"],
						["C6", "H62"], ["C8", "H81"], ["C8", "H82"], ["C8", "H83"],
						["N1", "HN1"]],
				# "HOH" => [[]],
				# " ZN" => [[]],
				"NO3" => [[]],
				"ACT" => [["CH3","H1"],["CH3","H2"],["CH3","H3"]],
				"EDO" => [["C1","H11"],["C1","H12"],["C2","H21"],["C2","H22"],["O1","HO1"],["O2","HO2"]],
				"V8M" => [["H061","C06"],["H092","C09"],["H011","C01"],["H081","C08"],["H181","C18"],["H091","C09"],
						["H042","C04"],["H111","C11"],["H112","C11"],["H141","C14"],["H271","C27"],
						["H161","C16"],["H121","C12"],["H221","C22"],["H191","C19"],["H051","C05"],["H082","C08"],
						["H102","C10"],["H041","C04"],["H101","C10"],["H281","C28"],
						["H192","C19"],["H052","C05"],["H131","C13"]],
)
