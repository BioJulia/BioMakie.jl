import Base.convert
indexshift(idxs,shift=1.0) = try
	float.(idxs).+=shift .|> Int
catch
	float.(idxs).+=shift
end
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
macro lock(l, expr)
    quote
        temp = $(esc(l))
        lock(temp)
        try
            $(esc(expr))
        finally
            unlock(temp)
        end
    end
end
function varcall(name::String,body::Any)
    name=Symbol(name)
    @eval (($name) = ($body))
	return Symbol(name)
end
function reversekv(dict::AbstractDict{K,V}; print = false) where {K,V}
	vkdict = [x[2].=>x[1] for x in dict]
	if print == true
		println.(vkdict)
	end
	return OrderedDict{V,K}(vkdict)
end
dfr(x) = DataFrame(x)
dfr(xs...) = DataFrame(xs...)
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
function kdict(str::String)
    if length(str) == 3
        kideradict3["$str"]
    elseif length(str) == 1
        kideradict["$str"]
    else
        throw(ErrorException("can't get kdict for $str"))
    end
end
kdict(c::Char) = kdict(string(c))
function steprange(arr::AbstractArray{T,1}; step = 1) where {T<:Real}
    start_value = arr[1]
    end_value = arr[end]
	start_value == end_value && error("the start and end points are the same value")
    for i in 1:size(arr,1)
        if i == 1
            step = arr[i+1] - arr[i]
        end
        if arr[i]-arr[i-1] != step
            error("inconsistent step for step range")
        end
    end
    return StepRange(min_value,step,max_value)
end
function unitrange(arr::AbstractArray{T,1}) where {T<:Int}
    start_value = arr[1]
    end_value = arr[end]
    end_value == start_value && error("the start and end points are the same value")
	end_value < start_value && error("the last value is lower than the first")
    for i in 1:size(arr,1)
        if i == 1
            step = arr[i+1] - arr[i]
        end
        if arr[i]-arr[i-1] != 1
            error("inconsistent step for unit range")
        end
    end
    return UnitRange(start_value,end_value)
end
splatrange(range) = [(range...)]
function splatranges(ranges...)
    splattedrange = []
    for range in ranges
        splattedrange = vcat(splattedrange, splatrange(range))
    end
    return eval([Int64.(splattedrange)...])
end
carbonselector(at) = element(at) in ("C","CA","CB")
nitroselector(at) = element(at) == "N"
nothydrogenselector(at) = element(at) != "H"
fullbbselector(at) = atomname(at) ∈ ("N","CA","C","O")
sidechainselector(at) = !fullbbselector(at)
resselector(at, res = "GLY") = resname(at) == "$res"
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
function resmass(res::BioStructures.Residue)
    total = 0.0
    for atm in res
        total+=atomicmasses["$(element(atm, strip=true))"]
    end
    return total
end
function resvdw(res::BioStructures.Residue)
    total = 0.0
    for atm in res
        total+=vdw["$(element(atm, strip=true))"]
    end
    return total
end
function makeclrgrad(vec::AbstractArray{T}, colrmap::AbstractArray) where T<:Real
    softmaxvec = Flux.softmax(vec)
    scalefactor = size(colrmap,1) / maximum(softmaxvec)
    colorindices = round.(Int64, softmaxvec .* scalefactor)
    indexedcolors = colrmap[colorindices]
    return indexedcolors
end
∑(x) = sum(x)
(D::Dict)(i::Int) = Dict([keys(D)...][i] => [values(D)...][i])
(D::OrderedDict)(i::Int) = OrderedDict([keys(D)...][i] => [values(D)...][i])
(D::Dict)(is::AbstractVector{Int}) = Dict([([keys(D)...][i],[values(D)...][i]) for i in is])
(D::OrderedDict)(is::AbstractVector{Int}) = OrderedDict([([keys(D)...][i],[values(D)...][i]) for i in is])
(D::Dict)(is::Int...) = D([is...])
(D::OrderedDict)(is::Int...) = D([is...])
(D::Dict)(is::AbstractRange{Int}) = D([is...])
(D::OrderedDict)(is::AbstractRange{Int}) = D([is...])
(D::Dict)(is::AbstractRange{Int}...) = D([(is...)...])
(D::OrderedDict)(is::AbstractRange{Int}...) = D([(is...)...])
function (D::AbstractDict)(is...)
    indices = []
    for i in is
        if typeof(i) <: Union{AbstractRange{Int},AbstractArray{Int}}
            for j in i
                push!(indices, j)
            end
        elseif typeof(i) <: Int
            push!(indices, i)
        else
            error("could not index this, arguments must be Ints, ranges of Ints, arrays of Ints, or a combo of those")
        end
    end
    return D(indices...)
end
function centerofpoints(points::AbstractArray{T}) where T <: Number
    xs = points[:,1]
    ys = points[:,2]
    zs = points[:,3]
    return centerofpoints = [ ∑(xs)/size(xs,1), ∑(ys)/size(ys,1), ∑(zs)/size(zs,1) ] |> _g
end
function centerofmass(atms::AbstractArray{AbstractAtom})
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
function linesegs(arrN23::AbstractArray{Float64,3})
    new_arr::AbstractArray{Point3f0} = []
    for N in 1:size(arrN23,1)
        push!(new_arr, Makie.Point3f0(arrN23[N,1,:]))
        push!(new_arr, Makie.Point3f0(arrN23[N,2,:]))
    end
    return new_arr |> combinedims |> transpose |> collect
end
function transposed(arr::AbstractArray)
	arr2 = arr
    try
        @cast arr[j,i] := arr[i,j]
        arr2 = arr |> dfr |> Array
    catch
        arr2 = permutedims(arr[:,1])
        for i = 2:size(arr,2)
            arr2 = vcat(arr2, permutedims(arr[:,i]))
        end
    end
    return arr2
end
_t(arr::AbstractArray) = transposed(arr)
_v(arr::AbstractArray) = reverse(arr; dims = 1)
_h(arr::AbstractArray) = reverse(arr; dims = 2)
function _stripkeys(dict::AbstractDict)
    ks = string.(strip.(keys(dict)))
    return ks
end
_stripallkeys(dicts::AbstractArray) =  _stripkeys.(dicts)
_shuffledims!(arr::AbstractArray{T,1}) where {T}; arr
_shuffledims!(arr::AbstractArray{T,2}) where {T}; @cast arr[j,i] := arr[i,j]
_shuffledims!(arr::AbstractArray{T,3}, d::Int64 = 1) where {T}
	if d == 1
		@cast arr[i,k,j] := arr[i,j,k] # d==1 => index 1 is held
	elseif d == 2
		@cast arr[k,j,i] := arr[i,j,k] # d==2 => index 2 is held
	elseif d == 3
		@cast arr[j,i,k] := arr[i,j,k] # d==3 => index 3 is held
	elseif d == 0
		@cast arr[i,j,k] := arr[i,j,k] # d==0 => identity
	elseif d == 4 || d == +1
		@cast arr[k,i,j] := arr[i,j,k] # d==4 => move indices forward +1 ( index 3(+1) -> index 4 -> index 1 )
	elseif d == 5 || d == -1
		@cast arr[j,k,i] := arr[i,j,k] # d==5 => move indices backward -1 ( index 1(-1) -> index 0 -> index 3 )
	else
		@cast arr[i,j,k] := arr[i,j,k] # else => identity
end
