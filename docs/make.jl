using Documenter, BioMakie

makedocs(
    modules = [BioMakie],
    clean = false,
    format = Documenter.HTML(),
    sitename = "BioMakie",
    pages = Any["Home" => "index.md",
                "page1" => "pagel"],
)

deploydocs(repo = "github.com/kool7d/BioMakie.jl.git")
