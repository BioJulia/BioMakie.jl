using Documenter
using BioMakie

makedocs(
    sitename = "BioMakie.jl",
    pages=[
		"Home" => "index.md",
		"Usage" => "usage.md",
		"Examples" => [
			"MSA Selection" => "msaselection.md",
			"Alpha Shape" => "alphashape.md",
			"Info Text" => "infotext.md",
			"Mutation" => "mutation.md",
		]
		"API" => "API.md",
    ]
)

deploydocs(
	repo="github.com/kool7d/BioMakie.jl.git",
    push_preview=true
)
