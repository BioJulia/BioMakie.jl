"""
	StructureView is an object/container to hold relevant data for convenience.

	All fields except `scene` are `Observables/Nodes`, so they can be easily tracked
	and used to trigger updates and events.

	Fields:
		id 				- PDB ID by default
		chains			- Structure chains
		residues		- Structure residues
		atoms			- Structure atoms
		scene			- The scene showing the structure
"""
mutable struct StructureView
	id
	chains
	residues
	atoms
	scene
end
StructureView(xs::AbstractArray{Node}) = StructureView(xs..., nothing)
import BioStructures.chains
for f in (	:id,
			:chains,
			:residues,
			:atoms,
			:scene
			)
  @eval $(f)(sv::StructureView) = sv.$(f)[]
end
atomcoords(atoms) = coordarray(atoms) |> transpose |> collect
atomcoords(sv::StructureView) = atomcoords(atoms(sv))
atomcolors(atoms; color = "element") =
					if color == "ele" || color == "element" || color == :ele || color == :element
						[elecolors[element(x)] for x in atoms]
					elseif color == "aqua" || color == :aqua
						[aquacolors[element(x)] for x in atoms]
					else
						try
							d = @eval $(color)*"colors"
							[d[element(x)] for x in atoms]
						catch
							println("color dict not found")
						end
					end
atomradii(atoms) = [vanderwaals[element(x)] for x in atoms]
resids(residues) = resid.(residues)
resatoms(residues) = BioStructures.atoms.(residues)

"""
    structureview(prot::ProteinStructure; kwargs...)

Return a StructureView object for `prot`.

### Optional Arguments:
- dir (String)         				- Directory for PDB structure
- select (BioStructures selector) 	- Selector to use, default = :standardselector
- model	(Int)						- Structure model, default = 1

"""
function structureview( prot::ProteinStructure;
						dir = "",
						select = :standardselector,
						model = 1)
	#
	id1 = prot.name[1:end-4]
	model1 = prot[model]
	chains1 = BioStructures.chains(model1)
	residues1 = BioStructures.collectresidues(model1, eval(select))
	atoms1 = BioStructures.collectatoms(model1, eval(select))
	return StructureView(  map( X->Node(X),
								[ id1,
								  chains1,
							  	  residues1,
							  	  atoms1
								]))
end

"""
    structureview(str::String; kwargs...)

Return a StructureView object with PDB ID `"str"`.

### Optional Arguments:
- dir (String)         				- Directory for PDB structure
- select (BioStructures selector) 	- Selector to use, default = :standardselector
- model	(Int)						- Structure model, default = 1

"""
function structureview( str::String;
						dir = "",
						select = :standardselector,
						model = 1)

	if length(str) == 4
		return structureview(retrievepdb(uppercase(str); dir = dir), select = select, model = 1)
	else
		return structureview(read("$(dir)\\$(str)", BioStructures.PDB), select = select, model = 1)
	end

	return error("something wrong with the `structureview` input")
end

"""
    viewstrucs(strs::AbstractArray{String}; kwargs...)

Visualize all structures in the array `strs`.

### Optional Arguments:
- dir (String)         	- Directory of PDB structure, default `""`
- show_bonds (Boolean) 	- To display bonds, default `true`
- show_id (Boolean) 	- To display id, default `true`
- color (String)       	- Color set for atoms, default `"element"`

"""
function viewstrucs(strs::AbstractArray{T};
					dir = "",
					show_bonds = true,
					show_id = true,
					color = "element") where T
	#
	len = length(strs)
	len > 0 || throw("length of input for `viewstrucs` must be > 0")
	if T<:StructureView
		svs = strs
	else
		svs = [structureview(str; dir = dir) for str in strs]
	end
	flexres = (420*len,650)
	fig = GLMakie.Figure(resolution = flexres)

	for (i,sv) in enumerate(svs)
		sc = LScene(fig[1:8,i], resolution = (400,650))
		meshscatter!(sc, lift(atomcoords,sv.atoms);
			color = lift(X->atomcolors(X; color = color),sv.atoms),
			markersize = lift(X->(1/3).*atomradii(X),sv.atoms), show_axis = false)
		#
		if show_bonds == true
			shp1 = bondshapes.(bonds(residues(sv))) |> collectbondshapes
			bonds1 = normal_mesh.(shp1)
			mesh!(sc, bonds1[1], color = RGBAf0(0.5,0.5,0.5,0.8))
			for i = 1:size(bonds1,1); mesh!(sc, bonds1[i], color = RGBAf0(0.5,0.5,0.5,0.8)); end
		end
		sv.scene = sc
	end
	if show_id == true
		for (i,sv) in enumerate(svs)
			GLMakie.Label(fig[1,i], sv.id, tellwidth = false)
		end
	end
	display(fig)

    if len == 1
        return svs[1]
    end
	return svs
end
"""
    viewstruc(str::{String}; kwargs...)

Visualize structure with PDB ID `"str"`.

### Optional Arguments:
- dir (String)         - Directory of PDB structure, default `"../data/PDB"`
- showbonds (Boolean)  - To display bonds, default `true`
- color (String)       - Color set for atoms, default `"element"`

"""
viewstruc(str::String; kwargs...) = viewstrucs([str]; kwargs...)
viewstruc(stv::StructureView; kwargs...) = viewstrucs([stv]; kwargs...)
viewstruc(stv::ProteinStructure; kwargs...) = viewstrucs([stv]; kwargs...)
viewstrucs(str::String; kwargs...) = viewstrucs([str]; kwargs...)
viewstrucs(stv::StructureView; kwargs...) = viewstrucs([stv]; kwargs...)
viewstrucs(stv::ProteinStructure; kwargs...) = viewstrucs([structureview(stv)]; kwargs...)
viewstrucs(stvs::AbstractArray{ProteinStructure}; kwargs...) = viewstrucs([structureview.(stvs)...]; kwargs...)
