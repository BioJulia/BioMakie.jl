using Pkg
Pkg.add("Documenter")
using Documenter, BioMakie

makedocs(
    sitename="BioMakie",
    modules = [BioMakie],
    format = Documenter.HTML(),
    pages = Any["Home" => "index.md",
                "Page1" => "page1.md"],
)
using Documenter: DeployDecision
DeployDecision(all_ok = true,
    repo = "github.com/kool7d/BioMakie",
    subfolder = "docs",
    branch = "gh-pages")
deploydocs(
    repo = "github.com/kool7d/BioMakie",
    target = "docs",
    branch = "gh-pages")
# include("make.jl")
