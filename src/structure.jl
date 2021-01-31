"""
	StructureView is an object/container to hold relevant data for convenience.

	Fields:
		protein			- The protein structure
		models			- Structure models
		chains			- Structure chains
		residues		- Structure residues
		atoms			- Structure atoms
		figures			- Figures, Axes, and Plots
"""
mutable struct StructureView
	protein
	models
	chains
	residues
	atoms
	figures::AbstractArray{Figure}
end
StructureView(xs::AbstractArray{Node}) = StructureView(xs..., [])
import BioStructures.chains
for f in (	:protein,
			:models,
			:chains,
			:residues,
			:atoms,
			:figures
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
    structureview(str::String; kwargs...)

Return a StructureView object with PDB ID `"str"`.

### Optional Arguments:
- dir (String)         - Directory for PDB structure, default `""`
- showbonds (Boolean)  - To display bonds, default `true`
- colors (String)      - Color set for atoms, default `"element"`

"""
function structureview( prot::ProteinStructure;
						dir = "",
						select = :standardselector)

	models1 = BioStructures.models(prot)
	chains1 = BioStructures.chains(prot)
	residues1 = BioStructures.collectresidues(prot, eval(select))
	atoms1 = BioStructures.collectatoms(prot, eval(select))
	return StructureView(  map( X->Node(X),
								[ prot,
							  	  models1,
							  	  chains1,
							  	  residues1,
							  	  atoms1
								]))
end
function structureview(str::String;
						dir = "",
						select = :standardselector)

	if length(str) == 4
		return structureview(retrievepdb(uppercase(str); dir = dir), select = select)
	else
		return structureview(read("$(str)", BioStructures.PDB), select = select)
	end

	return error("something wrong with the `structureview` input")
end

"""
    viewstrucs(strs::AbstractArray{String}; kwargs...)

Visualize all structures in the array `strs`.

### Optional Arguments:
- dir (String)         - Directory of PDB structure, default `""`
- showbonds (Boolean)  - To display bonds, default `true`
- color (String)      - Color set for atoms, default `"element"`
- resolution (Tuple{Int})   - Resolution of the scene, default `(1500, 600)`

"""
# function viewstruc( sv::StructureView;
# 					dir = "",
# 					showbonds = true,
# 					color = "element",
# 					resolution = (1200,900)) where T
# 	#
# 	fig = GLMakie.Figure(resolution = resolution)
# 	ax1 = fig[1,1]
# 	meshscatter(ax1, lift(atomcoords,sv.atoms);
# 	color = lift(X->atomcolors(X; color = color),sv.atoms),
# 	markersize = lift(X->(1/3).*atomradii(X),sv.atoms), show_axis = false, resolution = (800,800))
# 	#
# 	shp1 = bondshapes.(bonds(residues(sv))) |> collectbondshapes
# 	bonds1 = normal_mesh.(shp1)
# 	mesh!(ax1, bonds1[1], color = RGBAf0(0.5,0.5,0.5,0.8))
# 	for i = 1:size(bonds1,1); mesh!(ax1, bonds1[i], color = RGBAf0(0.5,0.5,0.5,0.8)); end
#
# 	display(fig)
# 	push!(sv.figures,fig)
# 	return sv
# end
function viewstrucs(strs::AbstractArray{T};
					dir = "",
					showbonds = true,
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
		ax = LScene(fig[1,i])
		meshscatter!(ax, lift(atomcoords,sv.atoms);
			color = lift(X->atomcolors(X; color = color),sv.atoms),
			markersize = lift(X->(1/3).*atomradii(X),sv.atoms), show_axis = false, resolution = (400,650))
		#
		shp1 = bondshapes.(bonds(residues(sv))) |> collectbondshapes
		bonds1 = normal_mesh.(shp1)
		mesh!(ax, bonds1[1], color = RGBAf0(0.5,0.5,0.5,0.8))
		for i = 1:size(bonds1,1); mesh!(ax, bonds1[i], color = RGBAf0(0.5,0.5,0.5,0.8)); end
		push!(sv.figures,fig)
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

sv1 = structureview("2vb1")

vs1 = viewstruc(sv1)
vs2 = viewstrucs(["2vb1","1lw3","2vb1"])
