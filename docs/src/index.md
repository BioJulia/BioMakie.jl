# BioMakie.jl Documentation

```@meta
CurrentModule = BioMakie
```

```julia:./code/ex1
using JSServe
Page(exportable=true, offline=true)
#
using WGLMakie
WGLMakie.activate!()
set_theme!(resolution=(800, 600))
g = smallgraph(:dodecahedral)
graphplot(g, layout=Spring(dim=3), node_size=100)
```