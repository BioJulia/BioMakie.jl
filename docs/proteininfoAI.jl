# In this demo a structure is plotted along with information about the protein
# and a text box which can take advantage of OpenAI.jl to generate a description from
# a prompt.
using BioMakie
using BioStructures
using GLMakie
using OrderedCollections, JSON3

# Plot the structure.
pdb = retrievepdb("2vb1")
pdata = plottingdata(pdb)
fig = Figure()
fig = plotstruc!(fig,pdata)

# Get the data from the web database using the accession ID and read it.
getuniprotdata("P00698"; include_refs = true)
dat = readuniprotdata("P00698.json"; include_refs = true)
txtt = uniprotsummary(dat)

# Next you can add a textbox which prompts GPT-3.5-turbo to answer questions about 
# the protein (or whatever else). This requires an API key from OpenAI.
using OpenAI, TextWrap
# ENV["APIKEY"] = "{YOUR API KEY}}"
model = "gpt-3.5-turbo"
txt = Observable("")
tbox = Textbox(fig[2,:]; placeholder = "Ask GPT about this protein...", width = 500)

on(tbox.stored_string) do t
        r = create_chat(
        ENV["APIKEY"], 
        model,
        [Dict("role" => "user", "content"=> t)]
    )
    txt[] = wrap(r.response[:choices][begin][:message][:content]; width = 75)
end

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