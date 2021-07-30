export PDBe_downloader

using Base: download_url
using Downloads: download

"""
    PDBe_downloader(args)

Create and return a Makie Figure for a PDBe data downloader.
Source URL: "https://www.ebi.ac.uk/pdbe/api/pdb/entry/{entryname}/{pdbid}

Entries: ["Summary","Molecules","Assoc. Publications",
        "Ligands","Carbohydrate Polymer","Modified Residues",
        "Mutated Residues","Secondary Structure","Binding Sites"]

# Examples
```julia
fig = PDBe_downloader("2vb1")

pdbid = "2vb1" |> Node
fig = PDBe_downloader(pdbid)
```
Keyword arguments:
dir ---- Default - "."
"""
function PDBe_downloader(pdbid::String; dir=".")
    pdbid = Node(pdbid)
    entries = ["summary","molecules","publications",
                "ligand_monomers","carbohydrate_polymer","modified_AA_or_NA",
                "mutated_AA_or_NA","secondary_structure","binding_sites"]
    #
    buttonlabels = ["Summary","Molecules","Assoc. Publications",
                    "Ligands","Carbohydrate Polymer","Modified Residues",
                    "Mutated Residues","Secondary Structure","Binding Sites"]
    #
    pdberesturls(pid,entrycalls) = ["https://www.ebi.ac.uk/pdbe/api/pdb/entry/$(x)/$pid" for x in entrycalls]
    pdbjsonurl(url,pid) = (JSON.parsefile(download(url))[pid])[1]
    urls = @lift pdberesturls($pdbid,entries)
    fig = Figure(resolution=(600,800))
    fig[1:2,1:11] = buttongrid = GridLayout()
    buttons = buttongrid[1:9, 1] = [GLMakie.Button(fig, label = l,halign=:left,textsize=20) for l in buttonlabels] 
    uppdb = @lift uppercase($pdbid)
    supertitle = Label(fig[0,:], lift(x->"PDBe Download: "*"$(x)",uppdb), textsize = 35)
    for i in 1:9
        on(buttons[i].clicks) do n
            info = urls[][i]
            println("Downloaded data: $(info) as $(dir)/$(entries[i])_$(pdbid[]).json\n")
            download("https://www.ebi.ac.uk/pdbe/api/pdb/entry/$(entries[i])/$(pdbid[])","$(dir)/$(entries[i])_$(pdbid[]).json")
        end
    end
    fig
end
function PDBe_downloader(pdbid::Node; dir=".")
    entries = ["summary","molecules","publications",
                "ligand_monomers","carbohydrate_polymer","modified_AA_or_NA",
                "mutated_AA_or_NA","secondary_structure","binding_sites"]
    #
    buttonlabels = ["Summary","Molecules","Assoc. Publications",
                    "Ligands","Carbohydrate Polymer","Modified Residues",
                    "Mutated Residues","Secondary Structure","Binding Sites"]
    #
    pdberesturls(pid,entrycalls) = ["https://www.ebi.ac.uk/pdbe/api/pdb/entry/$(x)/$pid" for x in entrycalls]
    pdbjsonurl(url,pid) = (JSON.parsefile(download(url))[pid])[1]
    urls = @lift pdberesturls($pdbid,entries)
    fig = Figure(resolution=(600,800))
    fig[1:2,1:11] = buttongrid = GridLayout()
    buttons = buttongrid[1:9, 1] = [GLMakie.Button(fig, label = l,halign=:left,textsize=20) for l in buttonlabels] 
    uppdb = @lift uppercase($pdbid)
    supertitle = Label(fig[0,:], lift(x->"PDBe Download: "*"$(x)",uppdb), textsize = 35)
    for i in 1:9
        on(buttons[i].clicks) do n
            info = urls[][i]
            println("Downloaded data: $(info) as $(dir)/$(entries[i])_$(pdbid[]).json")
            download("https://www.ebi.ac.uk/pdbe/api/pdb/entry/$(entries[i])/$(pdbid[])","$(dir)/$(entries[i])_$(pdbid[]).json")
        end
    end
    fig
end
