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
	figures
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
bonds(residues) = resbonds.(residues; hres = true)
bondshapes(bonds) = bondshape.([bonds[i].bonds for i = 1:size(bonds,1)]) |> collectbondshapes

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
- colors (String)      - Color set for atoms, default `"element"`
- resolution (Tuple{Int})   - Resolution of the scene, default `(1500, 600)`

"""
# function viewstrucs(strs::AbstractArray{T};
# 					dir = "",
# 					showbonds = true,
# 					colors = "element",
# 					resolution = (1200,900)) where T
#
# 	len = length(strs)
# 	len > 0 || throw("length of input for `viewstrucs` must be > 0")
#
#     fig = GLMakie.Figure(resolution = resolution)
# 
# 	if T <:StructureView
# 		svs = strs
# 	else
# 		svs = [structureview(string(str); dir = dir) for str in strs]
# 	end
# 	sc_scene = fig[2:8,1:8] = Scene()
# 	axes = []
# 	plots = []
#     for i in 1:len
#         sc = sc_scenes[i]
#         layout[2:8,(end+1):(end+8)] = sc
#
#         axis1, plot1 = meshscatter(fig[2:8,end+1):(end+8)], lift(atomcoords,svs[i].atoms);
#             color = lift(X->atomcolors(X; color = colors2),svs[i].atoms),
#             markersize = lift(X->(1/3).*atomradii(X),svs[i].atoms), show_axis = false)
#         if showbonds == true
#     		bonds1 = normal_mesh.(bondshapes(bonds(residues(svs[i]))))
#     		mesh(axis1, bonds1[1], color = RGBAf0(0.5,0.5,0.5,0.0))
#     		for i = 1:size(bonds1,1); mesh(axis1, bonds1[i], color = RGBAf0(0.5,0.5,0.5,0.8)); end
#     	end
#         svs[i].figures = [fig,axis1,plot1]
#
#     end
#     # AbstractPlotting.display(scene)
#     # deletecol!(layout, 1)
#     if len == 1
#         return svs[1]
#     end
# 	return svs
# end
# """
#     viewstruc(str::{String}; kwargs...)
#
# Visualize structure with PDB ID `"str"`.
#
# ### Optional Arguments:
# - dir (String)         - Directory of PDB structure, default `"../data/PDB"`
# - showbonds (Boolean)  - To display bonds, default `true`
# - colors (String)      - Color set for atoms, default `"element"`
#
# """
# viewstruc(str::String; kwargs...) = viewstrucs([str]; kwargs...)
# viewstruc(stv::StructureView; kwargs...) = viewstrucs([stv]; kwargs...)
# viewstruc(stv::ProteinStructure; kwargs...) = viewstrucs([structureview(stv)]; kwargs...)
# viewstrucs(str::String; kwargs...) = viewstrucs([str]; kwargs...)
# viewstrucs(stv::StructureView; kwargs...) = viewstrucs([stv]; kwargs...)
# viewstrucs(stv::ProteinStructure; kwargs...) = viewstrucs([structureview(stv)]; kwargs...)
# viewstrucs(stvs::AbstractArray{ProteinStructure}; kwargs...) = viewstrucs([structureview.(stvs)...]; kwargs...)
