using Pkg
Pkg.add("Documenter")
using Documenter, BioMakie

makedocs(
    sitename="BioMakie",
    modules = [BioMakie],
    format = Documenter.HTML(),
    pages = ["Home" => "index.md",
             "Page1" => "page1.md"] )
