using Documenter, BioMakie

makedocs(;
    modules=[BioMakie],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/kool7d/BioMakie.jl/blob/{commit}{path}#L{line}",
    sitename="BioMakie.jl",
    authors="Daniel Kool",
    assets=String[],
)

deploydocs(;
    repo="github.com/kool7d/BioMakie.jl",
)
