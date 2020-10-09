using Pkg
Pkg.add("Documenter")
using Documenter, BioMakie

makedocs(
    sitename="BioMakie",
    modules = [BioMakie],
    clean = false,
    format = Documenter.HTML(),
    pages = Any["Home" => "index.md"],
)

deploydocs(repo = "github.com/kool7d/BioMakie")
