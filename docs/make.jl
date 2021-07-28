using Documenter, BioMakie

makedocs(sitename = "BioMakie",
    modules = [BioMakie],
    build   = "build",
    clean   = true,
    format = Documenter.HTML(),
    pages = ["Home" => "index.md",
            "GL Usage" => "GLusage.md",
            "WebGL/JSServe Usage" => "WGLusage.md",
            "API" => "api.md"]
        )

deploydocs(repo = "github.com/kool7d/BioMakie.jl.git",
            branch = "gh-pages",
            versions = ["stable" => "v^", "v#.#"],
            push_preview = true)
