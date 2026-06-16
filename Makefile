.PHONY: gen gen_heavyresbonds gen_hresbonds

gen: gen_heavyresbonds gen_hresbonds

gen_heavyresbonds: components.cif.gz
	uv run utils/gen_heavyresbonds.py > ./src/heavyresbonds.jl

gen_hresbonds: components.cif.gz
	uv run utils/gen_hresbonds.py > ./src/hresbonds.jl

components.cif.gz:
	wget https://files.wwpdb.org/pub/pdb/data/monomers/components.cif.gz
