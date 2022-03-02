## Walkthrough

# This walkthrough is intended to explain the construction of some of the plots so that the user can 
# more easily work with and modify them. 

# This first example illustrates some of the simplicity and flexibility of using `Makie` for working with 3D 
# data. Use the `BioStructures` package to load a protein structure from the Protein Data Bank (PDB).

using Pkg # hide
Pkg.activate() # hide
using BioStructures, WGLMakie
struc = retrievepdb("2vb1")

# Collect its atoms and make a 3D scatter plot. The `meshscatter` function returns a Makie `FigureAxisPlot`. 
# The easiest way to work with a `FigureAxisPlot` is to specify variable names for the returned objects. 
# These include the figure, the axis or scene, and what we just plotted onto it.

atms = collectatoms(struc);
cords = coordarray(atms);
meshfig, ax, plt = meshscatter(cords; show_axis = false, resolution = (800,600))

# You can also create the `Figure` first and then plot onto it.

fig = Figure(resolution = (800,600))
grid1 = fig[1:2,1:3] = GridLayout()
scene1 = LScene(grid1[:,:], scenekw = (camera = cam3d!, raw = false))
meshfig = meshscatter!(scene1, cords; show_axis = false)
fig

# Besides the excellent layouting capabilities, the real magic of Makie is in the `Observable` system. 
# Makie `Observable`s are variables that other variables can listen to. Wrap the atom coordinates in 
# an `Observable` before plotting them so that the plotting machinery will be able to respond. You can 
# include more `Observable`s for things like sliders and other controllers. Make the atom radius into an 
# `Observable` and pass it to `meshscatter` as `markersize`.

# You can make an `Observable` by using the constructor or with a pipe:

atmrad = Observable(0.5)
cords = coordarray(atms) |> Observable

# Here do the same thing to make the `Figure` but pass the plotting function the `Observable`s, so 
# they can be used later.

fig = Figure(resolution = (800,600))
grid1 = fig[1:2,1:3] = GridLayout()
scene1 = LScene(grid1[:,:], scenekw = (camera = cam3d!, raw = false))
meshfig = meshscatter!(scene1, cords; markersize = atmrad, show_axis = false)
fig

# Now that we have the `Figure`, we can add more to it. Since we used a `Observable` to display the coordinates 
# for the `meshscatter`, and a `Observable` for atom radius, let's add a slider to control the radius. The 
# `labelslider!` and `labelslidergrid!` functions can do this for one or multiple sliders, respectively. To set 
# a starting value, use `set_close_to!` on the labelslider's slider field.

radius = labelslider!(fig[1,end], "atom radius", 0.1:0.1:3.0;
                    startval = 1.0, format = x->"$(x) Å", width = 250, tellwidth = true, tellheight = false
)
fig[1,end+1] = radius.layout
set_close_to!(radius.slider, 1.0)

# To make it update the radius in the plot, we can set the atom radius to be the value of the slider.

on(radius.slider.value) do s
    atmrad[] = s
end

