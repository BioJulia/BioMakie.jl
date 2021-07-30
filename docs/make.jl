using BioMakie, Documenter, Literate

makedocs(; modules=[BioMakie], authors="Dan Kool",
    repo="https://github.com/kool7d/BioMakie.jl/blob/{commit}{path}#{line}",
    sitename="BioMakie.jl",
    format=Documenter.HTML(; prettyurls=get(ENV, "CI", "false") == "true",
                       canonical="https://JuliaPlots.github.io/BioMakie.jl", assets=String[]),

    pages = ["Home" => "index.md",
            "Usage" => "usage.md",
            "API" => "api.md"]
        )

deploydocs(;repo="github.com/kool7d/BioMakie.jl",
            push_preview=true)