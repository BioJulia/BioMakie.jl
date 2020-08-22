using Documenter, Literate
using AbstractPlotting, Makie, MakieLayout
# GENERATED = joinpath(@__DIR__, "src", "literate")
# SOURCE_FILES = joinpath.(GENERATED, ["examples.jl"])
# foreach(fn -> Literate.markdown(fn, GENERATED), SOURCE_FILES)

makedocs(
    sitename="BioMakie",
    format=Documenter.HTML(),
    pages = Any[
                "index.md",
                "Examples" => "literate/examples.md",
               ],
    repo="https://github.com/kool7d/BioMakie.jl.git"
)

deploydocs(
    repo="github.com/kool7d/BioMakie.jl.git"
)
# include("make.jl")
