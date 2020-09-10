using Flux3D, Flux, Makie, CUDA
using Flux: onehotbatch, onecold, onehot, crossentropy
using Statistics: mean
using Base.Iterators: partition
using JSServe, Observables, WGLMakie, AbstractPlotting
using JSServe: @js_str, onjs, with_session, onload, Button, TextField, Slider, linkjs, serve_dom
using JSServe.DOM
using GeometryBasics
using FileIO
using AbstractPlotting.MakieLayout
AbstractPlotting.inline!(false)
AbstractPlotting.set_theme!(show_axis = false)
