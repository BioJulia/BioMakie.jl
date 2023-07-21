using Documenter
using BioMakie

makedocs(
    sitename = "BioMakie.jl",
    pages=[
		"Home" => "index.md",
		"Usage" => "usage.md",
		# "Examples" => "Examples/alphashape.md",
		"API" => "API.md",
    ]
)

deploydocs(
	repo="github.com/kool7d/BioMakie.jl.git",
    push_preview=true
)
