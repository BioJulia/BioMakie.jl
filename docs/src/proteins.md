```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/master/src/proteins.jl"
```
```@example 1
using JSServe
Page(exportable=true, offline=true)
using WGLMakie
set_theme!(resolution=(800, 400))
using BioMakie
viewstruc("2vb1")
```
