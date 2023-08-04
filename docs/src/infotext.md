```@meta
EditURL = "https://github.com/kool7d/BioMakie.jl/blob/dev/docs/src/infotext.jl"
```

## Plotting Information Text
In this demo a structure is plotted along with information about the protein
and a text box which can take advantage of OpenAI.jl to generate a description from
a prompt.

````julia
using BioMakie
using BioStructures
using GLMakie
using OrderedCollections, JSON3
````

### Acquire the data
Use BioStructures to retrieve a PDB file, then prepare the plotting data.

````julia
pdb = retrievepdb("2vb1")
pdata = plottingdata(pdb)
````

Get the data from the web database using the associated accession ID and read it.

````julia
getuniprotdata("P00698"; include_refs = true)
dat = readuniprotdata("P00698.json"; include_refs = true)
txtt = uniprotsummary(dat)
````

### Plot the Structure and Text
First plot the structure.

````julia
fig = Figure()
fig = plotstruc!(fig,pdata)
````

Next you can add a textbox which prompts GPT-3.5-turbo to answer questions about
the protein (or whatever else). This requires an API key from OpenAI.

````julia
using OpenAI, TextWrap
ENV["APIKEY"] = "{YOUR API KEY}"
model = "gpt-3.5-turbo"
txt = Observable("")
tbox = Textbox(fig[2,:]; placeholder = "Ask GPT about this protein...", width = 500)
````

Use the text box to prompt GPT-3.5-turbo, and make it use the `txt` Observable.

````julia
on(tbox.stored_string) do t
        r = create_chat(
        ENV["APIKEY"],
        model,
        [Dict("role" => "user", "content"=> t)]
    )
    txt[] = wrap(r.response[:choices][begin][:message][:content]; width = 75)
end
````

Finally, plot the text for the protein information and prompt response.

````julia
ax = Axis(fig[3:4,:])
GLMakie.text!(ax, txt, fontsize = 16, align = (:left, :top))
xlims!(ax, (0, 1))
ylims!(ax, (-0.5, 0))
hidespines!(ax)
hideydecorations!(ax)
hidexdecorations!(ax)

ax = Axis(fig[1,2])
GLMakie.text!(ax, txtt, fontsize = 16, align = (:left, :top))
xlims!(ax, (0, 1))
ylims!(ax, (-0.5, 0))
hidespines!(ax)
hideydecorations!(ax)
hidexdecorations!(ax)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

