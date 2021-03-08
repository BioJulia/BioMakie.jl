```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/master/src/proteins.jl"
```
```@example 1
using JSServe
Page(exportable=true, offline=true)
```

After the page got displayed by the frontend, we can start with creating plots and JSServe Apps:

```@example 1
using WGLMakie
# Set the default resolution to something that fits the Documenter theme
set_theme!(resolution=(800, 400))
scatter(1:4, color=1:4)
```

As you can see, the output is completely static, because we don't have a running Julia server, as it would be the case with e.g. Pluto.
To make the plot interactive, we will need to write more parts of WGLMakie in JS, which is an ongoing effort.
As you can see, the interactivity already keeps working for 3D:

```@example 1
N = 60
function xy_data(x, y)
    r = sqrt(x^2 + y^2)
    r == 0.0 ? 1f0 : (sin(r)/r)
end
l = range(-10, stop = 10, length = N)
z = Float32[xy_data(x, y) for x in l, y in l]
surface(
    -1..1, -1..1, z,
    colormap = :Spectral
)
```
