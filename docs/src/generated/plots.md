```@meta
EditURL = "<unknown>/docs/pages/plots.jl"
```

# Plotting Graphs with `GraphMakie.jl`
## The `graphplot` Command
Plotting your first `AbstractGraph` from [`Graphs.jl`](https://github.com/JuliaGraphs/Graphs.jl)
is as simple as

````@example plots
using CairoMakie
set_theme!(resolution=(800, 400)) #hide
CairoMakie.inline!(true) # hide
using GraphMakie
using Graphs
import Random; Random.seed!(2) # hide

using GraphMakie.NetworkLayout

g = wheel_digraph(10)
arrow_size = [10+i for i in 1:ne(g)]
arrow_shift = range(0.1, 0.8, length=ne(g))
f, ax, p = graphplot(g; arrow_size, arrow_shift)
hidedecorations!(ax); hidespines!(ax); ax.aspect = DataAspect()
f # hide

set_theme!(resolution=(800, 800)) #hide
g = SimpleGraph(8); add_edge!(g, 1, 2); add_edge!(g, 3, 4); add_edge!(g, 5, 6); add_edge!(g, 7, 8)

waypoints = Dict(1 => [(.25,  0.25), (.75, -0.25)],
                 2 => [(.25, -0.25), (.75, -0.75)],
                 3 => [(.25, -0.75), (.75, -1.25)],
                 4 => [(.25, -1.25), (.75, -1.75)])
waypoint_radius = Dict(1 => nothing,
                       2 => 0,
                       3 => 0.05,
                       4 => 0.15)

f = Figure(); f[1,1] = ax = Axis(f)
using Makie.Colors # hide
for i in 3:4 #hide
    poly!(ax, Circle(Point2f(waypoints[i][1]), waypoint_radius[i]), color=RGBA(0.0,0.44705883,0.69803923,0.2)) #hide
    poly!(ax, Circle(Point2f(waypoints[i][2]), waypoint_radius[i]), color=RGBA(0.0,0.44705883,0.69803923,0.2)) #hide
end #hide

p = graphplot!(ax, g; layout=SquareGrid(cols=2, dy=-0.5),
               waypoints, waypoint_radius,
               nlabels=["","r = nothing (equals :spline)",
                        "","r = 0 (straight lines)",
                        "","r = 0.05 (in data space)",
                        "","r = 0.1"],
               nlabels_distance=30, nlabels_align=(:left,:center))

for i in 1:4 #hide
    scatter!(ax, waypoints[i], color=RGBA(0.0,0.44705883,0.69803923,1.0)) #hide
end #hide
xlims!(ax, (-0.1, 2.25)), hidedecorations!(ax); hidespines!(ax); ax.aspect = DataAspect()
f # hide
````

## Plot Graphs in 3D
If the layout returns points in 3 dimensions, the plot will be in 3D. However this is a bit
experimental. Feel free to file an issue if there are any problems.

````@example plots
set_theme!(resolution=(800, 800)) #hide
g = smallgraph(:cubical)
elabels_shift = [0.5 for i in 1:ne(g)]
elabels_shift[[2,7,8,9]] .= 0.3
elabels_shift[10] = 0.25
graphplot(g; layout=Spring(dim=3, seed=5),
          elabels="Edge ".*repr.(1:ne(g)),
          elabels_textsize=12,
          elabels_opposite=[3,5,7,8,12],
          elabels_shift,
          elabels_distance=3,
          arrow_show=true,
          arrow_shift=0.9,
          arrow_size=15)

using JSServe
Page(exportable=true, offline=true)
````

````@example plots
using WGLMakie
WGLMakie.activate!()
set_theme!(resolution=(800, 600))
g = smallgraph(:dodecahedral)
gp = graphplot(g, layout=Spring(dim=3), node_size=100)
gp
````

## Record a statemap

````@example plots
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
````

## Record a statemap

must be true to be found inside the DOM

````@example plots
is_widget(x) = true
````

Updating the widget isn't dependant on any other state (only thing supported right now)

````@example plots
is_independant(x) = true
````

The values a widget can iterate

````@example plots
function value_range end
````

updating the widget with a certain value (usually an observable)

````@example plots
function update_value!(x, value) end

using Observables
using JSServe: Slider

App() do session::Session
    n = 10
    index_slider = Slider(1:n)
    volume = rand(n, n, n)
    slice = map(index_slider) do idx
        return volume[:, :, idx]
    end
    fig = Figure()
    ax, cplot = contour(fig[1, 1], volume)
    rectplot = linesegments!(ax, Rect(-1, -1, 12, 12), linewidth=2, color=:red)
    on(index_slider) do idx
        translate!(rectplot, 0,0,idx)
    end
    heatmap(fig[1, 2], slice)
    slider = DOM.div("z-index: ", index_slider, index_slider.value)
    return JSServe.record_states(session, DOM.div(slider, fig))
end
````

## Record a statemap

````@example plots
using JSServe
using JSServe: @js_str, App
using JSServe.DOM
using JSServe, Observables
using JSServe: @js_str, Session, App, onjs, onload, Button
using JSServe: TextField, Slider, linkjs, get_server
using JSServe.DOM
using JSServe: JSON3
````

Javascript & CSS dependencies can be declared locally and
freely interpolated in the DOM / js string, and will make sure it loads

````@example plots
const THREE = JSServe.Dependency(:THREE,["https://cdn.jsdelivr.net/gh/mrdoob/three.js/build/three.min.js"])

App() do session::Session
    width = 500; height = 500
    dom = DOM.div(width = width, height = height)
    JSServe.onload(session, dom, js"""
        function (container){

            var renderer = new $(THREE).WebGLRenderer({antialias: true});
            renderer.setSize($width, $height);
            renderer.setClearColor("#ffffff");
            container.appendChild(renderer.domElement);
            renderer.setPixelRatio( window.devicePixelRatio );

            //
            // requestAnimationFrame( animate );

            var scene = new $THREE.Scene();
            var camera = new $THREE.PerspectiveCamera(75, $width / $height, 0.1, 1000);
            camera.position.z = 4;
            var ambientLight = new $THREE.AmbientLight(0xcccccc, 0.4);
            scene.add(ambientLight);
            var pointLight = new $THREE.PointLight(0xffffff, 0.8);
            camera.add(pointLight);
            scene.add(camera);
            // var geometry = new $THREE.TorusKnotGeometry( 50, 10, 50, 20 );
            var material = new $THREE.MeshPhongMaterial({color: 0xffff00});

            object = new $THREE.Mesh( new $THREE.CylinderGeometry( 25, 75, 100, 40, 5 ), material );
            object.position.set( - 300, 0, - 200 );
            scene.add( object );

            object = new $THREE.Mesh( new $THREE.TorusGeometry( 50, 20, 20, 20 ), material );
            object.position.set( 100, 0, - 200 );
            scene.add( object );

            object = new $THREE.Mesh( new $THREE.TorusKnotGeometry( 50, 10, 50, 20 ), material );
            object.position.set( 300, 0, - 200 );
            scene.add( object );

            object = new $THREE.Mesh( new $THREE.PlaneGeometry( 100, 100, 4, 4 ), material );
            object.position.set( - 300, 0, 0 );
            scene.add( object );

            object = new $THREE.Mesh( new $THREE.BoxGeometry( 100, 100, 100, 4, 4, 4 ), material );
            object.position.set( - 100, 0, 0 );
            scene.add( object );

            object = new $THREE.Mesh( new $THREE.CircleGeometry( 50, 20, 0, Math.PI * 2 ), material );
            object.position.set( 100, 0, 0 );
            scene.add( object );

            object = new $THREE.Mesh( new $THREE.RingGeometry( 10, 50, 20, 5, 0, Math.PI * 2 ), material );
            object.position.set( 300, 0, 0 );
            scene.add( object );

            object = new $THREE.Mesh( new $THREE.CylinderGeometry( 25, 75, 100, 40, 5 ), material );
            object.position.set( - 300, 0, - 200 );
            scene.add( object );

            camera.position.z = 200
            camera.position.x = 100
            camera.position.y = 200
            camera.lookAt( 0, 0, 0 );
            function render() {

				const timer = Date.now() * 0.0001;

				camera.position.x = Math.cos( timer ) * 800;
				camera.position.z = Math.sin( timer ) * 800;

				camera.lookAt( scene.position );

				scene.traverse( function ( object ) {

					if ( object.isMesh === true ) {

						object.rotation.x = timer * 5;
						object.rotation.y = timer * 2.5;

					}

				} );

				renderer.render( scene, camera );

			};
            function animate() {

                requestAnimationFrame( animate );
                render();
            };
            animate();
        }
    """)
    return dom
end
````

## Record a statemap

const GUI = JSServe.Dependency(:GUI,["https://github.com/mrdoob/three.js/blob/master/examples/jsm/libs/lil-gui.module.min.js"])
const OrbitControls = JSServe.Dependency(:OrbitControls,["https://github.com/mrdoob/three.js/blob/master/examples/jsm/controls/OrbitControls.js"])
const TransformControls = JSServe.Dependency(:TransformControls,["https://github.com/mrdoob/three.js/blob/master/examples/jsm/controls/TransformControls.js"])

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

