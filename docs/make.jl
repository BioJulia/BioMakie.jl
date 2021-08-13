using Documenter, BioMakie

makedocs(; modules=[BioMakie], authors="Dan Kool",
    sitename="BioMakie.jl",
    format=Documenter.HTML(; prettyurls=get(ENV, "CI", "false") == "true",
                       canonical="https://kool7d.github.io/BioMakie.jl/stable", assets=String[]),

    pages = ["Home" => "index.md",
             "API" => "API.md"]
)
include("make.jl")