using Documenter, BioStructures
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
