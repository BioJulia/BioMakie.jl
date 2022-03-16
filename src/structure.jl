"""
    atomcoords(atoms)

Convenience function for collecting atom coordinates for plotting.
"""
atomcoords(atoms) = coordarray(atoms) |> transpose |> collect

"""
    atomradii(atoms)

Collect atom radii for plotting.
Uses BioStructures to get radii based on atomic element.

Keyword arguments:
radiustype = :vdw for vanderwaals, :cov for covalent. (Default is covalent)
"""
function atomradii(atoms; radiustype = :cov)
	if radiustype == :cov || radiustype == :covalent
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	elseif radiustype == :vdw || radiustype == :vanderwaals
		return [vanderwaalsradii[BioStructures.element(x)] for x in atoms]
	else
		return [covalentradii[BioStructures.element(x)] for x in atoms]
	end
end

"""
    resatoms(res)

Collect the atoms from a residue as an OrderedDict.
"""
function resatoms(res::AbstractResidue)
	resvec1 = [k for k in res]
	resvec2 = [(resvec1[i].name, coords(resvec1[i])) for i in 1:size(resvec1,1)]
	return OrderedDict(resvec2)
end

"""
    plotstruc!(figure, structure)

Plot a protein structure into a Figure. Position can be specified with the 
gridposition keyword argument.

# Examples
```julia
fig = Figure()
using BioStructures
struc = retrievepdb("2vb1", dir = "data/") |> Observable
sv = plotstruc!(fig, struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
sv = plotstruc!(fig, struc)
```
Keyword Arguments:
selectors ----- Default - [standardselector]
resolution ---- Default - (800,800)
gridposition -- Default - (1,1)
plottype ------ Default - :ballandstick, another option is :spacefilling
atomcolors ---- Default - elecolors, another option is aquacolors, or define your own dict for atoms like: "N" => :blue
"""
function plotstruc!(fig::Figure, struc::T;
                    selectors = [standardselector],
                    resolution = (800,800),
                    gridposition = (1,1),
                    plottype = :ballandstick,
                    atomcolors = elecolors
                    ) where {T<:BioStructures.StructuralElementOrList}
	#
    atms = @lift BioStructures.collectatoms($struc,selectors...)
    atmcords = @lift coordarray($atms) |> transpose |> collect
    colrs = @lift [atomcolors[BioStructures.element(x)] for x in $atms]
    bnds = @lift BioMakie.getbonds(collectresidues($struc,selectors...))
    bbnds = @lift backbonebonds.(collectchains($struc))

    if plottype == :spacefilling
        marksize = @lift atomradii($atms; radiustype = :vdw)
        lscene = LScene(fig[gridposition...]; show_axis = false)
        meshscatter!(lscene, atmcords; color = colrs, markersize = marksize)
    elseif plottype == :ballandstick
        marksize = @lift atomradii($atms; radiustype = :cov)
        lscene = LScene(fig[gridposition...]; show_axis = false)
        meshscatter!(lscene, atmcords; color = colrs, markersize = marksize)
		# :ballandstick shows the bonds (/sticks) as cylinder meshes in the same space as the atom meshscatter.
		# Could it be improved by making different shapes for single, double, and triple bonds? 
        resshps = @lift bondshape.(SplitApplyCombine.flatten(BioMakie.getbonds(collectresidues($struc,selectors...))))
        bbshps = @lift bondshape.(SplitApplyCombine.flatten(backbonebonds.(collectchains($struc))))
        resbnds = @lift normal_mesh.($resshps)
        bckbnds = @lift normal_mesh.($bbshps)
        mesh!(lscene, resbnds, color = RGBA(0.5,0.5,0.5,0.8))
        mesh!(lscene, bckbnds, color = RGBA(0.5,0.5,0.5,0.8))
    else
        println("bad plottype")
    end
end

"""
    plotstruc(structure)

Create and return a Makie Figure for a protein structure, 
along with the structure wrapped in an Observable if it wasn't Observable already. 

# Examples
```julia
using BioStructures
struc = retrievepdb("2vb1", dir = "data/") |> Observable
sv = plotstruc(struc)

struc = read("data/2vb1_mutant1.pdb", BioStructures.PDB) |> Observable
sv = plotstruc(struc)
```
Keyword Arguments:
selectors ----- Default - [standardselector]
resolution ---- Default - (800,800)
gridposition -- Default - (1,1)
plottype ------ Default - :ballandstick, another option is :spacefilling
atomcolors ---- Default - elecolors, another option is aquacolors, or define your own dict for atoms like: "N" => :blue
"""
function plotstruc(struc; kwargs...)
	fig = Figure()

	# It wants the struc to be an Observable.
	if typeof(struc) != Observable
		struc = Observable(struc)
		plotstruc!(fig, struc; kwargs...)

		# If it wasn't given an Observable from the user, it also returns the Observable.
		return fig, struc
	else
		plotstruc!(fig, struc; kwargs...)
		return fig
	end
end
