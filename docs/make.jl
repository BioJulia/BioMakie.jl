push!(LOAD_PATH, "../src")

using Documenter, BioMakie

DocMeta.setdocmeta!(BioMakie, :DocTestSetup, :(begin
    using BioMakie;
    using BioStructures;
    using MIToS;
    using MIToS.MSA;
end); recursive=true)

makedocs(;
    modules = [BioMakie],
    authors="Daniel Kool",
    repo="https://github.com/kool7d/BioMakie.jl/blob/{commit}{path}#{line}",
    sitename="BioMakie.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kool7d.github.io/BioMakie.jl",
        assets=String[],
    ),
    pages = [
        "Home" => "index.md",
        "Structures" => "structures.md"
    ],
    doctest = true,
)

deploydocs(
    repo="github.com/kool7d/BioMakie.jl.git",
    target = "build",
    push_preview = true,
)
