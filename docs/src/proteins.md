```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/master/src/proteins.jl"
```

# Proteins

## Structures

You can load a Protein Structure from the PDB (Protein Data Bank):

```@example proteins
pstruc1 = viewstruc("2VB1")
```

## Multiple sequence alignments

You can similarly load a Multiple Sequence Alignment from the Pfam database:

```@example proteins
msa1 = viewmsa("PF00062")
```

```@example 1
using JSServe
Page(exportable=true, offline=true)
```

```@example 1
using WGLMakie
# Set the default resolution to something that fits the Documenter theme
set_theme!(resolution=(800, 400))
scatter(1:4, color=1:4)
```

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

```@example 1
using Observables

App() do session::Session
    n = 10
    index_slider = Slider(1:n)
    volume = rand(n, n, n)
    slice = map(index_slider) do idx
        return volume[:, :, idx]
    end
    fig = Figure()
    ax, cplot = contour(fig[1, 1], volume)
    rectplot = linesegments!(ax, Rect(-1, -1, 12, 12), linewidth=50, color=:red)
    on(index_slider) do idx
        translate!(rectplot, 0,0,idx)
    end
    heatmap(fig[1, 2], slice)
    slider = DOM.div("z-index: ", index_slider, index_slider.value)
    return JSServe.record_states(session, DOM.div(slider, fig))
end
```

```@example 1
using JSServe: onjs

app = App() do session::Session
    s1 = Slider(1:100)
    slider_val = DOM.p(s1[]) # initialize with current value
    # call the `on_update` function whenever s1.value changes in JS:
    onjs(session, s1.value, js"""function on_update(new_value) {
        //interpolating of DOM nodes and other Julia values work mostly as expected:
        const p_element = $(slider_val)
        p_element.innerText = new_value
    }
    """)

    return DOM.div("slider 1: ", s1, slider_val)
end
```
---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
