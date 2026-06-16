import gemmi
import json

doc = gemmi.cif.read_file("components.cif.gz")

print("# Collection of known hydrogen covalent bonds, for a PDB structure file. The knowledge-based bonds defined here are retrieved directly from https://www.wwpdb.org/.")
# Build the Dict via one assignment per residue rather than a single huge Dict(...)
# literal: a literal with tens of thousands of entries overflows Julia's interpreter
# during precompilation (segfault), whereas successive top-level assignments do not.
print("hresbonds = Dict{String,Vector{Tuple{String,String}}}()")
for block in doc:
    name = block.name

    bonds = []

    for row in block.find("_chem_comp_bond.", [
        "atom_id_1",
        "atom_id_2"
    ]):
        # row.str() removes CIF quoting, giving the true atom name (which may
        # itself contain a `'` prime or `"` double-prime, e.g. O2', C5'').
        a = row.str(0)
        b = row.str(1)

        # not a bond involving hydrogen atoms
        if not (a[0] == "H" or b[0] == "H"): continue

        # json.dumps emits a properly quoted/escaped Julia string literal.
        # Each bond is an immutable tuple (no per-bond Vector header) to save memory.
        bonds.append(f'({json.dumps(a)},{json.dumps(b)})')

    print(f'hresbonds[{json.dumps(name)}] = [{",".join(bonds)}]')
