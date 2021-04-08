using Documenter, BioMakie

makedocs(repo = "github.com/kool7d/BioMakie",
    sitename = "BioMakie",
    modules = [BioMakie],
    build   = "build",
    clean   = true,
    format = Documenter.HTML(),
    pages = Any["Home" => "index.md",
                "GL Usage" => "GLusage.md",
                "WebGL/JSServe Usage" => "WGLusage.md"])

deploydocs(target = build,
            repo = "github.com/kool7d/BioMakie",
            branch = "gh-pages",
            versions = ["stable" => "v^", "v#.#"],
            push_preview = false)
