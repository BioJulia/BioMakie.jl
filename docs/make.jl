using Pkg
Pkg.add("Documenter")
using Documenter, BioMakie

makedocs(
    sitename="BioMakie",
    modules = [BioMakie],
    build = "",
    format = Documenter.HTML(),
    pages = Any["Home" => "index.md",
                "Page1" => "page1.md"])

deploydocs(
    repo = "github.com/kool7d/BioMakie",
    target = "docs",
    build = ""
    branch = "gh-pages")
# include("make.jl")
