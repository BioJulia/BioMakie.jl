export heatmap,
       heatmap!

import Makie.heatmap
import Makie.heatmap!
using PairwiseListMatrices, NamedArrays
using MIToS.PDB

"""
    heatmap( dmap; kwargs... )

Plot a MIToS distance map.

# Example
    
```julia
using MIToS.PDB

pdbfile = MIToS.PDB.downloadpdb("1IVO", format=PDBFile)
residues_1ivo = read(pdbfile, PDBFile)
pdb = @residues residues_1ivo model "1" chain "A" group "ATOM" residue All
dmap = MIToS.PDB.distance(pdb, criteria="All")

heatmap(dmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- :viridis
- kwargs... -------------- additional keyword arguments to pass to heatmap
"""
function heatmap(dmap::NamedMatrix{Float64, PairwiseListMatrix{Float64, false, Vector{Float64}}, 
                Tuple{OrderedDict{String, Int64}, OrderedDict{String, Int64}}}; xlabel = "Item 2", 
                ylabel = "Item 1", colormap = :ice, kwargs...)
    fig = Figure()
    ax = Axis(fig[1,1])
    dmap_1 = dmap.dicts[1] |> reversekv
    dmap_2 = dmap.dicts[2] |> reversekv
    dat = reverse(Matrix(dmap); dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(dmap_1[i[2]]): $(i[2])\n$(dmap_1[i[1]]): " *
        "$(i[1])\nvalue: $(round(dat[i...];digits=6))",
                    colormap = colormap, kwargs...)
    Colorbar(fig[1,2],hm)

    ax.xlabel = dmap.dimnames[2]
    ax.ylabel = dmap.dimnames[1]
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end

"""
    heatmap!( fig, dmap; kwargs... )

Plot a MIToS distance map.

# Example
    
```julia
fig = Figure()

using MIToS.PDB

pdbfile = MIToS.PDB.downloadpdb("1IVO", format=PDBFile)
residues_1ivo = read(pdbfile, PDBFile)
pdb = @residues residues_1ivo model "1" chain "A" group "ATOM" residue All
dmap = MIToS.PDB.distance(pdb, criteria="All")

heatmap!(fig, dmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- :viridis
- kwargs... -------------- additional keyword arguments to pass to heatmap
"""
function heatmap!(fig::Figure, dmap::NamedMatrix{Float64, PairwiseListMatrix{Float64, false, Vector{Float64}}, 
                Tuple{OrderedDict{String, Int64}, OrderedDict{String, Int64}}}; xlabel = "Item 2", 
                ylabel = "Item 1", colormap = :ice, kwargs...)
    ax = Axis(fig[1,1])
    dmap_1 = dmap.dicts[1] |> reversekv
    dmap_2 = dmap.dicts[2] |> reversekv
    dat = reverse(Matrix(dmap); dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(dmap_1[i[2]]): $(i[2])\n$(dmap_1[i[1]]): " *
        "$(i[1])\nvalue: $(round(dat[i...];digits=6))",
        colormap = colormap, kwargs...)
    Colorbar(fig[1,2],hm)

    ax.xlabel = dmap.dimnames[2]
    ax.ylabel = dmap.dimnames[1]
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end

"""
    heatmap( cmap; kwargs... )

Plot a MIToS contact map.

Example:
    
```julia
using MIToS.PDB

pdbfile = MIToS.PDB.downloadpdb("1IVO", format=PDBFile)
residues_1ivo = read(pdbfile, PDBFile)
pdb = @residues residues_1ivo model "1" chain "A" group "ATOM" residue All
cmap = contact(pdb, 8.0, criteria="CB")

heatmap(cmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- Colormap to use
- kwargs... -------------- additional keyword arguments to pass to heatmap
"""
function heatmap(cmap::NamedMatrix{Bool, PairwiseListMatrix{Bool, false, Vector{Bool}}, 
                Tuple{OrderedDict{String, Int64}, OrderedDict{String, Int64}}}; xlabel = "Item 2", 
                ylabel = "Item 1", colormap = :ice, kwargs...)
    fig = Figure()
    ax = Axis(fig[1,1])
    cmap_1 = cmap.dicts[1] |> reversekv
    cmap_2 = cmap.dicts[2] |> reversekv
    dat = reverse(Matrix(cmap); dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(cmap_1[i[2]]): $(i[2])\n$(cmap_1[i[1]]): " *
        "$(i[1])\nvalue: $(round(dat[i...];digits=6))",
                    colormap = colormap, kwargs...)
    
    ax.xlabel = cmap.dimnames[2]
    ax.ylabel = cmap.dimnames[1]
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end

"""
    heatmap!( fig, cmap; kwargs... )

Plot a MIToS contact map.

Example:
    
```julia
fig = Figure()

using MIToS.PDB

pdbfile = MIToS.PDB.downloadpdb("1IVO", format=PDBFile)
residues_1ivo = read(pdbfile, PDBFile)
pdb = @residues residues_1ivo model "1" chain "A" group "ATOM" residue All
cmap = contact(pdb, 8.0, criteria="CB")

heatmap!(fig, cmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- :ice
- kwargs... -------------- additional keyword arguments to pass to heatmap
"""
function heatmap!(fig::Figure, cmap::NamedMatrix{Bool, PairwiseListMatrix{Bool, false, Vector{Bool}}, 
                Tuple{OrderedDict{String, Int64}, OrderedDict{String, Int64}}}; xlabel = "Item 2", 
                ylabel = "Item 1", colormap = :ice, kwargs...)
    ax = Axis(fig[1,1])
    cmap_1 = cmap.dicts[1] |> reversekv
    cmap_2 = cmap.dicts[2] |> reversekv
    dat = reverse(Matrix(cmap); dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(cmap_1[i[2]]): $(i[2])\n$(cmap_1[i[1]]): " *
        "$(i[1])\nvalue: $(round(dat[i...];digits=6))",
        colormap = colormap, kwargs...)

    ax.xlabel = cmap.dimnames[2]
    ax.ylabel = cmap.dimnames[1]
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end

"""
    heatmap( dmap; kwargs... )

Plot a BioStructures distance map.

# Example
    
```julia
using BioStructures

struc = retrievepdb("1IVO")[1]
cbetas_A = collectatoms(struc["A"], cbetaselector)
cbetas_B = collectatoms(struc["B"], cbetaselector)
dmap = DistanceMap(cbetas_A, cbetas_B)
heatmap(dmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- :viridis
- kwargs... -------------- additional keyword arguments to pass to heatmap
"""
function heatmap(dmap::DistanceMap; xlabel = "Item 2", ylabel = "Item 1", colormap = :viridis, kwargs...)
    fig = Figure()
    ax = Axis(fig[1,1])
    dat = reverse(dmap.data; dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(i[2])  $(i[1])\nvalue: $(round(dat[i...];digits=5))",
                    colormap = colormap, kwargs...)
    Colorbar(fig[1,2],hm)

    ax.xlabel = xlabel
    ax.ylabel = ylabel
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end

"""
    heatmap( dmap; kwargs... )

Plot a BioStructures distance map.

# Example
    
```julia
using BioStructures

struc = retrievepdb("1IVO")[1]
cbetas_A = collectatoms(struc["A"], cbetaselector)
cbetas_B = collectatoms(struc["B"], cbetaselector)
dmap = DistanceMap(cbetas_A, cbetas_B)
heatmap(dmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- :viridis
- kwargs... -------------- additional keyword arguments to pass to heatmap
"""
function heatmap!(fig::Figure, dmap::DistanceMap; xlabel = "Item 2", ylabel = "Item 1", colormap = :viridis, kwargs...)
    ax = Axis(fig[1,1])
    dat = reverse(dmap.data; dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(i[2])  $(i[1])\nvalue: $(round(dat[i...];digits=5))",
                    colormap = colormap, kwargs...)
    Colorbar(fig[1,2],hm)

    ax.xlabel = xlabel
    ax.ylabel = ylabel
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end

"""
    heatmap( cmap; kwargs... )

Plot a BioStructures contact map.

# Example
    
```julia
using BioStructures

struc = retrievepdb("1IVO")[1]
cbetas_A = collectatoms(struc["A"], cbetaselector)
cbetas_B = collectatoms(struc["B"], cbetaselector)
cmap = ContactMap(cbetas_A, cbetas_B)
heatmap(cmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- :ice
- kwargs... -------------- additional keyword arguments to pass to heatmap
"""
function heatmap(cmap::ContactMap; xlabel = "Item 2", ylabel = "Item 1", colormap = :ice, kwargs...)
    fig = Figure()
    ax = Axis(fig[1,1])
    dat = reverse(cmap.data; dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(i[2])  $(i[1])\nvalue: $(round(dat[i...];digits=5))",
                    colormap = colormap, kwargs...)

    ax.xlabel = xlabel
    ax.ylabel = ylabel
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end

"""
    heatmap!( fig, cmap; kwargs... )

Plot a BioStructures contact map.

# Example
    
```julia
fig = Figure()

using BioStructures

struc = retrievepdb("1IVO")[1]
cbetas_A = collectatoms(struc["A"], cbetaselector)
cbetas_B = collectatoms(struc["B"], cbetaselector)
cmap = ContactMap(cbetas_A, cbetas_B)
heatmap!(fig, cmap)
```

### Keyword Arguments:
- xlabel ----------------- "Item 2"
- ylabel ----------------- "Item 1"
- colormap --------------- :ice
- kwargs... -------------- Keyword arguments to pass to heatmap
"""
function heatmap!(fig::Figure, cmap::ContactMap; xlabel = "Item 2", ylabel = "Item 1", colormap = :ice, kwargs...)
    ax = Axis(fig[1,1])
    dat = reverse(cmap.data; dims = 1)

    hm = heatmap!(ax, dat; inspector_label = (self, i, p) -> "$(i[2])  $(i[1])\nvalue: $(round(dat[i...];digits=5))",
                    colormap = colormap, kwargs...)

    ax.xlabel = xlabel
    ax.ylabel = ylabel
    ax.xlabelsize = 20
    ax.ylabelsize = 20
    ax.xlabelpadding = 15
    ax.ylabelpadding = 15
    DataInspector(fig)
    fig
end
