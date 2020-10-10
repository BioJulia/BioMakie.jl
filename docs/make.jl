using Pkg
Pkg.add("Documenter")
using Documenter, BioMakie

makedocs(
    sitename = "BioMakie",
    modules = [BioMakie],
    build   = "build",
    clean   = true,
    format = Documenter.HTML(),
    pages = ["Home" => "index.md",
            "Basics" => "basics.md",
            "Proteins" => "proteins.md",
            "API" => "API.md"])

deploydocs(
    repo = "github.com/kool7d/BioMakie",
    branch = "gh-pages",
    target = "docs")
