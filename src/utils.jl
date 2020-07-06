GLFW.WindowHint(GLFW.FLOATING, 1)
import Base.convert
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
function varcall(name::String,body::Any)
    name=Symbol(name)
    @eval (($name) = ($body))
	return Symbol(name)
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
_v(arr::AbstractArray) = reverse(arr; dims = 1)
_h(arr::AbstractArray) = reverse(arr; dims = 2)
function _stripkeys(dict::AbstractDict)
    ks = string.(strip.(keys(dict)))
    return ks
end
_stripallkeys(dicts::AbstractArray) =  _stripkeys.(dicts)
