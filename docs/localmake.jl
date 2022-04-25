#! julia

using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(PackageSpec(path=dirname(@__DIR__))) # adds the package this script is called from
Pkg.instantiate()
Pkg.update()

include("make.jl")

using LiveServer
@async LiveServer.serve(dir=joinpath(@__DIR__, "build"))
