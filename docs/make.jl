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
            "Page1" => "page1.md"])

deploydocs(
    repo = "github.com/kool7d/BioMakie",
    branch = "gh-pages",
    target = "docs")
