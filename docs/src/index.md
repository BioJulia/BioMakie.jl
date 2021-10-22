# BioMakie.jl

## Usage

### Structures
  
Let's start by loading a protein structure from the Protein Data Bank (PDB) with BioStructures.
```@repl
Pkg.add("BioStructures") # hide
using BioStructures
struc = retrievepdb("2vb1")
```
Now let's collect its atoms and make a 3D scatter plot. The `meshscatter` function returns a Makie `FigureAxisPlot`. The easiest 
way to work with those components is to specify variable names for three returned objects. These include the figure, axis or 
scene, and what we just plotted onto it.
```@repl
atms = collectatoms(struc)
cords = coordarray(atms)
meshfig, ax, plt = meshscatter(cords; 
                                markersize = 1.0, 
                                color = :lightgreen, 
                                show_axis = false, 
                                resolution = (800,600))
```
We could also have created the `Figure` first and then plotted onto it.
```@repl
fig = Figure(resolution = (800,600))
grid1 = fig[1:2,1:3] = GridLayout()
scene1 = LScene(grid1[:,:], scenekw = (camera = cam3d!, raw = false))
meshfig = meshscatter!(scene1, cords; 
                        markersize = 1.0, 
                        color = :green, 
                        show_axis = false)
fig
```
Besides the excellent layouting capabilities, the real magic of Makie is in the `Node` system. Makie `Node`s are variables that
other variables can listen to. Wrap the atom coordinates in a `Node` before plotting them so that the plotting machinery will be 
able to respond to manipulations/updates of its value, and other behavior you give it. We can include more `Node`s for things 
like sliders and other controllers. Let's also make the atom radius into a `Node` and pass it to `meshscatter` as `markersize`.

There are at least 2 ways to make a `Node`:
```@repl
cords = coordarray(atms) |> Node
atmrad = Node(0.5)
```
Here we do the same thing to make the `Figure` but we pass the plotting function our `Node`s, so that we can manipulate things later.
```@repl
fig = Figure(resolution = (800,600))
grid1 = fig[1:2,1:3] = GridLayout()
scene1 = LScene(grid1[:,:], scenekw = (camera = cam3d!, raw = false))
meshfig = meshscatter!(scene1, cords; markersize = atmrad, color = :green, show_axis = false)
fig
```
Now that we have the `Figure`, we can add more to it. Since we used a `Node` to display the coordinates for the `meshscatter`,  
and a `Node` for atom radius, let's add a slider to control the radius. The `labelslider!` and `labelslidergrid!` functions can 
do this for one or multiple sliders. To set a starting value, use `set_close_to!` on the labelslider's slider field.
```@repl
radius = labelslider!(fig[1,end], "atom radius", 0.1:0.1:3.0; 
                    startval = 1.0, format = x->"$(x) Å", width = 250, tellwidth = true, tellheight = false
)
fig[1,end+1] = radius.layout
set_close_to!(radius.slider, 1.0)
```
To make it update the radius in the plot, we can set the atom radius to be the value of the slider.
```@repl
on(radius.slider.value) do s
   atmrad[] = s 
end
```

Let's start by loading a protein structure from the Protein Data Bank (PDB) with BioStructures.
```@example
using BioStructures
struc = retrievepdb("2vb1")
```
Now let's collect its atoms and make a 3D scatter plot. The `meshscatter` function returns a Makie `FigureAxisPlot`. The easiest 
way to work with those components is to specify variable names for three returned objects. These include the figure, axis or 
scene, and what we just plotted onto it.
```@example
atms = collectatoms(struc)
cords = coordarray(atms)
meshfig, ax, plt = meshscatter(cords; 
                                markersize = 1.0, 
                                color = :lightgreen, 
                                show_axis = false, 
                                resolution = (800,600))
```
We could also have created the `Figure` first and then plotted onto it.
```@example
fig = Figure(resolution = (800,600))
grid1 = fig[1:2,1:3] = GridLayout()
scene1 = LScene(grid1[:,:], scenekw = (camera = cam3d!, raw = false))
meshfig = meshscatter!(scene1, cords; 
                        markersize = 1.0, 
                        color = :green, 
                        show_axis = false)
fig
```
Besides the excellent layouting capabilities, the real magic of Makie is in the `Node` system. Makie `Node`s are variables that
other variables can listen to. Wrap the atom coordinates in a `Node` before plotting them so that the plotting machinery will be 
able to respond to manipulations/updates of its value, and other behavior you give it. We can include more `Node`s for things 
like sliders and other controllers. Let's also make the atom radius into a `Node` and pass it to `meshscatter` as `markersize`.

There are at least 2 ways to make a `Node`:
```@example
cords = coordarray(atms) |> Node
atmrad = Node(0.5)
```
Here we do the same thing to make the `Figure` but we pass the plotting function our `Node`s, so that we can manipulate things later.
```@example
fig = Figure(resolution = (800,600))
grid1 = fig[1:2,1:3] = GridLayout()
scene1 = LScene(grid1[:,:], scenekw = (camera = cam3d!, raw = false))
meshfig = meshscatter!(scene1, cords; markersize = atmrad, color = :green, show_axis = false)
fig
```
Now that we have the `Figure`, we can add more to it. Since we used a `Node` to display the coordinates for the `meshscatter`,  
and a `Node` for atom radius, let's add a slider to control the radius. The `labelslider!` and `labelslidergrid!` functions can 
do this for one or multiple sliders. To set a starting value, use `set_close_to!` on the labelslider's slider field.
```@example
radius = labelslider!(fig[1,end], "atom radius", 0.1:0.1:3.0; 
                    startval = 1.0, format = x->"$(x) Å", width = 250, tellwidth = true, tellheight = false
)
fig[1,end+1] = radius.layout
set_close_to!(radius.slider, 1.0)
```
To make it update the radius in the plot, we can set the atom radius to be the value of the slider.
```@example
on(radius.slider.value) do s
   atmrad[] = s 
end
```
