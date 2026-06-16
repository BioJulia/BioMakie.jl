using MolecularGraph: ATOMTABLE, ATOMSYMBOLMAP, ATOM_COVALENT_RADII, ATOM_VANDERWAALS_RADII

ATOMSYMBOLKEYS = keys(ATOMSYMBOLMAP) |> collect
atomicmasses = Dict{String,Float32}(ATOMSYMBOLKEYS.=>[ATOMTABLE[ATOMSYMBOLMAP[x]]["Weight"] for x in ATOMSYMBOLKEYS])

# MolecularGraph keys its tables in title-case ("Mg", "Ca", "Fe"), but BioStructures reports
# element strings in uppercase ("MG", "CA", "FE"). Add an uppercase alias for every key so
# lookups by either convention succeed (e.g. metal ions in DNA structures like 7CZL).
function _addupperaliases!(d::AbstractDict)
	for (k, v) in collect(d)
		up = uppercase(k)
		get!(d, up, v)
	end
	return d
end
_addupperaliases!(atomicmasses)

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
_addupperaliases!(covalentradii)

# VanderWaals radii
_vdwrad = []
for x in ATOMSYMBOLKEYS
	try
		(push!(_vdwrad,Dict{String,Float32}(x=>ATOM_VANDERWAALS_RADII[ATOMTABLE[ATOMSYMBOLMAP[x]]["Number"]])))
	catch
	end
end
vanderwaalsradii = merge(_vdwrad...)
_addupperaliases!(vanderwaalsradii)
