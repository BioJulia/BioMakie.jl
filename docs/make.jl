using Documenter
using BioMakie

makedocs(
    sitename = "BioMakie.jl",
    pages=[
		"Home" => "index.md",
		"Examples" => [
			"MSA Selection" => "msaselection.md",
			"Alpha Shape" => "alphashape.md",
			"Database Info" => "dbinfo.md",
			"Mutation" => "mutation.md",
		],
		"API" => "API.md"
    ]
)

deploydocs(
	repo="github.com/kool7d/BioMakie.jl.git",
    push_preview=true
)

# using Literate
# Literate.markdown("src/dbinfo.jl", "src")
