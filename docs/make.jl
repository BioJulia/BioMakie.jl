using BioMakie
using Documenter
using Literate
using PkgDeps
using MIToS
using GLMakie
using GLMakie: Observable

DocMeta.setdocmeta!(BioMakie, :DocTestSetup, :(using BioMakie); recursive=true)

# examples = [
#     "./src/index.jl",
# ]

# for ex in examples
#     Literate.markdown(ex, "src")
# end

makedocs(; modules=[BioMakie], authors="Daniel Kool",
         repo="https://github.com/kool7d/BioMakie.jl/blob/{commit}{path}#{line}",
         sitename="BioMakie.jl",
         format=Documenter.HTML(; canonical="https://kool7d.github.io/BioMakie.jl"),
         pages=["Home" => "index.md",
                "Examples" => "Examples/alphashape.md",
                "API" => "API.md",
                ]
)

deploydocs(;repo="github.com/kool7d/BioMakie.jl",
           push_preview=true)
