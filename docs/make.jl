using Documenter, BioMakie

makedocs(
    sitename = "BioMakie",
    modules = [BioMakie],
    build   = "build",
    clean   = true,
    format = Documenter.HTML())

deploydocs(
    repo = "github.com/kool7d/BioMakie",
    branch = "gh-pages",
    target = "build")
