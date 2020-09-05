using Documenter, BioMakie

push!(LOAD_PATH, "../src/")

makedocs(
    sitename = "BioMakie",
    modules = [BioMakie],
    format=Documenter.HTML(),
    pages = Any[
                "Home" => "index.md",
                "Next page" => "index0.md"
                ],
)

deploydocs(
    repo="github.com/kool7d/BioMakie.jl.git",
    target = "build",
    push_preview = true,
    )
