push!(LOAD_PATH,"../src/")
using Documenter
using BioMakie
# using Literate
# using PkgDeps
# using MIToS
# using GLMakie
# using GLMakie: Observable

# DocMeta.setdocmeta!(BioMakie, :DocTestSetup, :(using BioMakie); recursive=true)

makedocs(; modules=[BioMakie], authors="Daniel Kool",
         sitename="BioMakie.jl",
         format=Documenter.HTML(; canonical="https://kool7d.github.io/BioMakie.jl"),
         pages=["Home" => "index.md",
                "Usage" => "usage.md",
              #   "Examples" => "Examples/alphashape.md",
                "API" => "API.md",
                ]
)

# deploydocs(;repo="github.com/kool7d/BioMakie.jl",
#               push_preview=true)
