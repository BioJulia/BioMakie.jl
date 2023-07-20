using Documenter
using .BioMakie

makedocs(
    sitename = "BioMakie",
    format = Documenter.HTML(),
    modules = [BioMakie]
)

deploydocs(
    repo = "github.com/kool7d/BioMakie.jl.git",
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
