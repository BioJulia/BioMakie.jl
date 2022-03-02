using BioMakie
using Documenter
using GLMakie
using CairoMakie
using WGLMakie
using GraphMakie
using Documenter
using Literate

using JSServe
using NetworkDynamics
using LayeredLayouts
using Graphs
using PkgDeps
using BioStructures
using MIToS

DocMeta.setdocmeta!(BioMakie, :DocTestSetup, :(using BioMakie); recursive=true)

# generate examples
# examples = [
#     joinpath(@__DIR__, "pages", "plots.jl"),
# ]
# OUTPUT = joinpath(@__DIR__, "src", "generated")
# # isdir(OUTPUT) && rm(OUTPUT, recursive=true)
# mkpath(OUTPUT)

# for ex in examples
#     Literate.markdown(ex, OUTPUT)
# end
# Literate.markdown("C:/Users/kool7/Google Drive/BioMakie.jl/docs/src/usage.jl", "C:/Users/kool7/Google Drive/BioMakie.jl/docs/src/")

makedocs(; modules = [BioMakie],
    authors="Daniel Kool",
    repo="https://github.com/kool7d/BioMakie.jl/blob/{commit}{path}#{line}",
    sitename="BioMakie.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kool7d.github.io/BioMakie.jl"),
    pages = [
        "Home" => "index.md",
        "Pages" => [
                    "Usage" => "generated/usage.md",
                    # "Walkthrough" => "generated/walkthrough.md",
                ]
    ]
)

deploydocs(;repo="github.com/kool7d/BioMakie.jl",
    push_preview = true)
