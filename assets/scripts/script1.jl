using Flux3D, Flux, CUDA
using Flux: onehotbatch, onecold, onehot, crossentropy
using Statistics
using AbstractPlotting
using Base.Iterators: partition
# using JSServe, Observables, WGLMakie, AbstractPlotting
# using JSServe: @js_str, onjs, with_session, onload, Button, TextField, Slider, linkjs, serve_dom
# using JSServe.DOM
using GeometryBasics
using FileIO
using UnPack
using OrdinaryDiffEq, DiffEqFlux, AlgebraOfGraphics
using DiffEqFlux: sciml_train
using Flux: glorot_uniform, ADAM
using Optim: LBFGS
using ComponentArrays
using AbstractPlotting.MakieLayout
AbstractPlotting.inline!(false)
AbstractPlotting.set_theme!(show_axis = false)

dsspfile = open("C:/Users/kool7/Google Drive/Prots/data/Secondary Struc/dssp-dataset-normal.txt",read = true)
readline(dsspfile) |> print
data1 = [readline(dsspfile) for i = 1:1000]
data1 = data1[1:900]
# writedlm("C:/Users/kool7/Google Drive/Prots/data/Secondary Struc/dsspnormal.csv",data1,',')

function gatherdssp(data::AbstractArray)
    ids = String[]
    seqs = String[]
    sstr = String[]

    for i = 1:size(data,1)
        if contains(data[i],'>')
            push!(ids,data[i][2:end])
        elseif contains(data[i-1],'>')
            push!(seqs,data[i][1:end])
        elseif contains(data[i-2],'>')
            push!(sstr,data[i][1:end])
        end
    end

    return ids, seqs, sstr
end

ids1, seqs1, sstr1 = gatherdssp(data1)
chains1 = [ids1[i][5] for i in 1:300]
p1 = retrievepdb(ids1[1][1:4];dir = "C:/Users/kool7/Google Drive/Prots/data/PDB")
p2 = retrievepdb(ids1[2][1:4];dir = "C:/Users/kool7/Google Drive/Prots/data/PDB")
p1a = p1["A"]
p2a = p2["A"]
p1as = sstr1[1]
p2as = sstr1[2]
