using Pkg
Pkg.activate(@__DIR__)

using Documenter, BioMakie

push!(LOAD_PATH, "../Documentation/")
const CI = get(ENV, "CI", nothing) == "true"

makedocs(
    sitename = "BioMakie",
    modules = [BioMakie],
    format=Documenter.HTML(prettyurls = CI),
    pages = Any[
                "Home" => "index.md",
                "Menu1" => "menu1.md",
                "Menu2" => "menu2.md",
                "Menu3" => "menu3.md"
                ],
)

if CI
    deploydocs(
        repo="github.com/kool7d/BioMakie.jl.git",
        target = "build",
        push_preview = true,
    )
end
