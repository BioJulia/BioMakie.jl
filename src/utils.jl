using MolecularGraph: UndirectedGraph
import Base.convert
import BioStructures.defaultatom, BioStructures.defaultresidue
defaultatom(at::BioStructures.Atom) = at
defaultresidue(res::BioStructures.Residue) = res
convert(::BioStructures.Atom,disat::DisorderedAtom) = defaultatom(disat)

function convert(::Type{T}, arr::Array{T,1}) where {T<:Number}
    if size(arr,1) > 1
        return T.(arr)
    end
    return T(arr[1])
end
function convert(::Type{Array{T}}, t::T) where {T<:Number}
    return [t]
end
function convert(::Type{T}, arr::Array{T,1}) where {T<:AbstractString}
    if size(arr,1) > 1
        return T.(arr)
    end
    return T(arr[1])
end
convert(::Type{String}, i::Int) = "$i"
function convert(::Type{String}, f::T) where T<:Union{Float16,Float32,Float64}
	"$f"
end
function collectall(args...; maxdepth = 5, currentdepth = 1)
	ff = []
	f1 = collect([args...])
	f2 = collect([Base.Iterators.flatten(f1)...])

    for x in f2
		if typeof(x) <: Union{AbstractArray,AbstractRange} && currentdepth < maxdepth
			xx = try
                collect([Base.Iterators.flatten(x)...])
            catch
                collect(x)
            end
			push!(ff,collectall(xx; maxdepth, currentdepth = currentdepth+1)...)
		else
			push!(ff,x)
		end
	end

	typ = typeof(ff[1])
    try
        ff = Vector{typ}(ff)
    catch

    end

	return ff
end
function collectkeys(args)
    return keys(args) |> collect
end
function collectvals(args)
    return values(args) |> collect
end
function reversekv(dict::AbstractDict{K,V}) where {K,V}
	vkdict = [x[2].=>x[1] for x in dict]
    if typeof(dict) <: OrderedDict
        return OrderedDict{V,K}(vkdict)
    end
	return Dict{V,K}(vkdict)
end
pdbS(x; kwargs...) = try
        retrievepdb(x; kwargs...)
    catch
        println("$(x) doesn't work, sorry")
    end
pdbM(x; model = "1", group = "ATOM", kwargs...) = try
        read("$pdbdir\\$(x).pdb", MIToS.PDB.PDBFile, model = "1", group = "ATOM", kwargs...)
    catch
        pdbS(x; kwargs...)
    end
anynan(x) = any(isnan.(x))
indexshift(idxs) = (idxs).+=1
function tryint(number)
    return (try
        Int64(number)
    catch
        number
    end)
end
function tryfloat(number)
    return (try
        Float64(number)
    catch
        number
    end)
end
function tryfloat32(number)
    return (try
        Float32(number)
    catch
        number
    end)
end
function unitrange(arr::AbstractVector{T}) where {T<:Int}
    start_value = arr[1]
    end_value = arr[end]
    end_value == start_value && error("the start and end points are the same value")
	end_value < start_value && error("the last value is lower than the first")
    for i in 2:size(arr,1)
        if arr[i]-arr[i-1] != 1
            error("inconsistent step for unit range")
        end
    end
    return UnitRange(start_value,end_value)
end
function steprange(arr::AbstractVector{T}) where {T<:Real}
    start_value = arr[1]
    end_value = arr[end]
	start_value == end_value && error("the start and end points are the same value")
    step = 1
    for i in 2:size(arr,1)
        if i == 2
            step = arr[i]-arr[i-1]
        end
        if arr[i]-arr[i-1] != step
            error("inconsistent step for step range")
        end
    end
    return StepRangeLen(start_value,step,length(arr))
end
splatrange(range) = [(range...)]
function splatranges(ranges...)
    splattedrange = []
    for range in ranges
        splattedrange = vcat(splattedrange, splatrange(range))
    end
    return eval([Int64.(splattedrange)...])
end
function internaldistances(atms::AbstractVector{AbstractAtom})
    internaldists = zeros(Float64, (size(atms,1),size(atms,1)))
    for (i,x) in enumerate(atms)
        for (j,y) in enumerate(atms)
            internaldists[i,j] = Distances.euclidean(BioStructures.coords(x),BioStructures.coords(y))
        end
    end
    return internaldists
end
function internaldistances(vals::AbstractArray{Number})
    internaldists = zeros(Float64, (size(vals,1),size(vals,1)))
    for (i,x) in enumerate(vals)
        for (j,y) in enumerate(vals)
            internaldists[i,j] = Distances.euclidean(x,y)
        end
    end
    return internaldists
end
function internaldistances(vals::AbstractArray)
    internaldists = zeros(Float64, (size(vals,1),size(vals,1)))
    for i in 1:size(vals,1)
        for j in 1:size(vals,1)
            internaldists[i,j] = Distances.euclidean(vals[i,:],vals[j,:])
        end
    end
    return internaldists
end
function internaldistorders(internaldists::AbstractArray)
    orders = zeros(Float64, (size(internaldists,1),size(internaldists,2)))
    for i = 1:size(internaldists,1)
        orders[i,:] = sortperm(sortperm(internaldists[i,:]))
    end
    return orders
end
function resmass(res::BioStructures.Residue)
    total = 0.0
    for atm in res
        total+=atomicmasses["$(element(atm, strip=true))"]
    end
    return total
end
function resvdw(res::BioStructures.Residue; scale = 1.0)
    total = 0.0
    for atm in res
        total+=vdwrad["$(element(atm, strip=true))"]
    end
    return total*scale
end
function makeclrgrad(vec::AbstractArray{T}, colrmap::AbstractArray) where {T<:Real}
    softmaxvec = Flux.softmax(vec)
    scalefactor = size(colrmap,1) / maximum(softmaxvec)
    colorindices = round.(Int64, softmaxvec .* scalefactor)
    indexedcolors = colrmap[colorindices]
    return indexedcolors
end
∑(x) = sum(x)
function centerofpoints(points::AbstractArray{T}) where {T<:Number}
    xs = points[:,1]
    ys = points[:,2]
    zs = points[:,3]
    return centerofpoints = [ ∑(xs)/size(xs,1), ∑(ys)/size(ys,1), ∑(zs)/size(zs,1) ]
end
function centerofmass(atms::AbstractArray)
    masses = []
    positions = coordarray(atms)
    xs = positions[1,:]
    ys = positions[2,:]
    zs = positions[3,:]
    totalmass = 0.0
    for i = 1:length(atms)
        if element(atms[i]) == "C"
            push!(masses, 12.0107)
            totalmass += 12.0107
        elseif element(atms[i]) == "N"
            push!(masses, 14.0067)
            totalmass += 14.0067
        elseif element(atms[i]) == "H"
            push!(masses,1.0079)
            totalmass += 1.0079
        elseif element(atms[i]) == "O"
            push!(masses, 15.9994)
            totalmass += 15.9994
        elseif element(atms[i]) == "S"
            push!(masses, 32.065)
            totalmass += 32.065
        else
            push!(masses, 0.0)
            totalmass += 0.0
        end
    end
    return centerofmass = [ ∑(masses.*xs)/totalmass, ∑(masses.*ys)/totalmass, ∑(masses.*zs)/totalmass ]
end
function surfacearea(coordinates, connectivity)
    totalarea = 0.0
    for i = 1:size(connectivity,1)
        totalarea += area(GeometryBasics.Point3f0.(coordinates[connectivity[i,1],:],
						coordinates[connectivity[i,2],:], coordinates[connectivity[i,3],:]))
    end
    return totalarea
end
function linesegs(arr::AbstractArray{T,3}) where {T<:AbstractFloat}
    new_arr::AbstractArray{Point3f0} = []
    for i in 1:size(arr,1)
        push!(new_arr, Makie.Point3f0(arr[i,1,:]))
        push!(new_arr, Makie.Point3f0(arr[i,2,:]))
    end
    return new_arr |> combinedims |> transpose |> collect
end
transposed(arr::AbstractArray) = transpose(arr) |> collect
_t(arr::AbstractArray) = transposed(arr)
_v(arr::AbstractArray) = reverse(arr; dims = 1)
_h(arr::AbstractArray) = reverse(arr; dims = 2)
function stripkeys(dict::AbstractDict)
    ks = string.(strip.(keys(dict)))
    return ks
end
stripallkeys(dicts::AbstractArray) =  stripkeys.(dicts)
elecolors = Dict( "C" => :gray,
                  "N" => :blue,
                  "H" => :white,
                  "O" => :red,
                  "S" => :yellow,
				  "X" => :gray,
				  "ZN" => :gray,
				  "CL" => :gray
)
aquacolors = Dict("C" => RGB(0.5,0.5,0.5),
                  "N" => RGB(0.472,0.211,0.499),
                  "H" => RGB(0.65,0.96,0.70),
                  "O" => RGB(0.111,0.37,0.999),
                  "S" => RGB(0.992,0.753,0.525),
				  "X" => RGB(0.5,0.5,0.5),
				  "ZN" => RGB(0.5,0.5,0.5),
				  "CL" => RGB(0.5,0.5,0.5)
)
SMILESaa = OrderedDict("A" => "N[C@@]([H])(C)C(=O)O",
        "R" => "N[C@@]([H])(CCCNC(=N)N)C(=O)O",
        "N" => "N[C@@]([H])(CC(=O)N)C(=O)O",
        "D" => "N[C@@]([H])(CC(=O)O)C(=O)O",
        "C" => "N[C@@]([H])(CS)C(=O)O",
        "Q" => "N[C@@]([H])(CCC(=O)N)C(=O)O",
        "E" => "N[C@@]([H])(CCC(=O)O)C(=O)O",
        "G" => "NCC(=O)O",
        "H" => "N[C@@]([H])(CC1=CN=C-N1)C(=O)O",
        "I" => "N[C@@]([H])([C@]([H])(CC)C)C(=O)O",
        "L" => "N[C@@]([H])(CC(C)C)C(=O)O",
        "K" => "N[C@@]([H])(CCCCN)C(=O)O",
        "M" => "N[C@@]([H])(CCSC)C(=O)O",
        "F" => "N[C@@]([H])(Cc1ccccc1)C(=O)O",
        "P" => "N1[C@@]([H])(CCC1)C(=O)O",
        "S" => "N[C@@]([H])(CO)C(=O)O",
        "T" => "N[C@@]([H])([C@]([H])(O)C)C(=O)O",
        "W" => "N[C@@]([H])(CC(=CN2)C1=C2C=CC=C1)C(=O)O",
        "Y" => "N[C@@]([H])(Cc1ccc(O)cc1)C(=O)O",
        "V" => "N[C@@]([H])(C(C)C)C(=O)O")
#
function protsmiles(aas::T) where {T}
    sm = ""
    if T<:String
        aas = string.([aas...])
    elseif T<:AbstractResidue
        aas = [resletterdict[aas[i].name] for i in 1:size(aas,1)]
    end

    for i in 1:(size(aas,1)-1)
        sm = sm*(SMILESaa[aas[i]][1:end-1])
    end
    sm = sm*(SMILESaa[aas[end]])

    return sm
end
function download_file(url::AbstractString, filename::AbstractString;
                        headers::Dict{String,String}=Dict{String,String}(),
                        kwargs...)
    HTTP.open("GET", url, headers; kwargs...) do stream
        open(filename, "w") do fh
            write(fh, stream)
        end
    end
    return filename
end
function download_file(url::AbstractString;
                        headers::Dict{String,String}=Dict{String,String}(),
                        kwargs...)
    download_file(url, tempname(); headers=headers, kwargs...)
end
function downloadpfam(pfamcode::String; filename::String="$pfamcode.stockholm.gz", kwargs...)
    @assert endswith(filename,".gz") "filename must end with the .gz extension"
    if occursin(r"^PF\d{5}$"i, pfamcode)
        number = pfamcode[3:end]
        download_file("http://pfam.xfam.org/family/PF$(number)/alignment/full/gzipped",
        filename; kwargs...)
    else
        throw(ErrorException("$pfamcode is not a correct Pfam code"))
    end
end
