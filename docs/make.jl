using Documenter, BioMakie

makedocs(
    modules = [BioMakie],
    clean = false,
    format = Documenter.HTML(),
    pages = Any["Home" => "index.md"],
)

deploydocs(repo = "github.com/kool7d/BioMakie.jl.git")
