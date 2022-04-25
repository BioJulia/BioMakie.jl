using BioMakie
using Documenter
using Literate
using PkgDeps

DocMeta.setdocmeta!(BioMakie, :DocTestSetup, :(using BioMakie); recursive=true)

# generate examples
examples = [
    joinpath(@__DIR__, "pages", "plotting.jl"),
]
OUTPUT = joinpath(@__DIR__, "src", "generated")
# # isdir(OUTPUT) && rm(OUTPUT, recursive=true)
# mkpath(OUTPUT)

for ex in examples
    Literate.markdown(ex, OUTPUT)
end

makedocs(; modules=[BioMakie], authors="Daniel Kool",
         repo="https://github.com/kool7d/BioMakie.jl/blob/{commit}{path}#{line}",
         sitename="BioMakie.jl",
         format=Documenter.HTML(; prettyurls=get(ENV, "CI", "false") == "true",
                                canonical="https://kool7d.github.io/BioMakie.jl"),
         pages=["Home" => "index.md",
                "Plotting" => "generated/plotting.md",
                "API" => "API.md",
                ]
)

deploydocs(;repo="github.com/kool7d/BioMakie.jl",
           push_preview=true)
