using Documenter
using BioMakie

makedocs(
    sitename = "BioMakie.jl",
    pages=[
		"Home" => "index.md",
		"Usage" => "usage.md",
		"Mesh" => "alphashape.md",
		"Info Text" => "infotext.md",
		"MSA Selection" => "msaselection.md",
		"API" => "API.md",
    ]
)

deploydocs(
	repo="github.com/kool7d/BioMakie.jl.git",
    push_preview=true
)
