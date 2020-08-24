using Documenter, Literate
using AbstractPlotting, Makie, MakieLayout

makedocs(
    sitename="BioMakie",
    # modules = [BioMakie],
    # format=Documenter.HTML(),
    pages = Any[
                "Home" => "index.md",
                "Examples" => "literate/examples.md",
    ],
    # repo="https://github.com/kool7d/BioMakie.jl.git"
)

# deploydocs(
    # repo="github.com/kool7d/BioMakie.jl.git"
# )
# include("make.jl")
