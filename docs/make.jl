using Pkg
Pkg.add("Documenter")
using Documenter, BioMakie

makedocs(
    sitename="BioMakie",
    modules = [BioMakie],
    clean = true,
    format = Documenter.HTML(),
    pages = Any["Home" => "index.md",
                "Page1" => "page1.md"],
)

deploydocs(repo = "github.com/kool7d/BioMakie")
# include("make.jl")
