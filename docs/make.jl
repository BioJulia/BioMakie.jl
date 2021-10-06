using Documenter
using BioMakie

DocMeta.setdocmeta!(BioMakie, :DocTestSetup, :(using BioMakie); recursive=true)

makedocs(;
    modules = [BioMakie],
    repo="https://github.com/kool7d/BioMakie.jl/blob/{commit}{path}#{line}",
    sitename="BioMakie.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kool7d.github.io/BioMakie.jl",
        assets=String[],
    )
)

deploydocs(
    repo="github.com/kool7d/BioMakie.jl.git",
    target = "build",
    push_preview = true,
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
# include("make.jl")