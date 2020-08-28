using Pkg
Pkg.activate(@__DIR__)

using Documenter, BioMakie

push!(LOAD_PATH, "../src/")
const CI = get(ENV, "CI", nothing) == "true"

makedocs(
    sitename = "BioMakie",
    modules = [BioMakie],
    format=Documenter.HTML(prettyurls = CI),
    pages = Any[
                "Home" => "index.md"
                ],
)

if CI
    deploydocs(
        repo="github.com/kool7d/BioMakie.jl.git",
        target = "build",
        push_preview = true,
    )
end
