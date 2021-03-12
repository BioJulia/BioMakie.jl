using Documenter, BioMakie

makedocs(repo = "github.com/kool7d/BioMakie",
    sitename = "BioMakie",
    modules = [BioMakie],
    build   = "build",
    clean   = true,
    format = Documenter.HTML(),
    pages = Any["Home" => "index.md",
                "Proteins" => "proteins.md"])

deploydocs(repo = "github.com/kool7d/BioMakie")
