using Documenter, BioMakie


makedocs(
    sitename = "BioMakie",
    modules = [BioMakie],
    format=Documenter.HTML(),
    pages = Any["Home" => "index.md"],
)
# Documenter.Travis()
deploydocs(
    repo="github.com/kool7d/BioMakie.jl.git"
)
# include("make.jl")
