GLFW.WindowHint(GLFW.FLOATING, 1)
function reversekv(dict::AbstractDict{K,V}; print = false) where {K,V}
	vkdict = [x[2].=>x[1] for x in dict]
	if print == true
		println.(vkdict)
	end
	return OrderedDict{V,K}(vkdict)
end
df(x) = DataFrame(x)
df(xs...) = DataFrame(xs...)
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
end
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
function steprange(arr::AbstractArray{T,1}; step = 1) where {T<:Integer}
    notseq = 0
    min_value = arr[1]
    max_value = arr[end]
    @assert max_value > min_value
    for i in 1:size(arr,1)
        if i == 1
            step = arr[i+1] - arr[i]
            continue
        end
        if arr[i]-arr[i-1] != step
            notseq = 1
        end
        if i == size(arr,1)
            break
        end
    end
    if notseq == 0
        return StepRange(min_value,step,max_value)
    end
    throw(ErrorException("cannot make this into a step range"))
end
function unitrange(arr::AbstractArray{T,1}) where {T<:Integer}
    notseq = 0
    min_value = arr[1]
    max_value = arr[end]
    @assert max_value > min_value
    for i in 1:size(arr,1)
        if i == 1
            step = arr[i+1] - arr[i]
            continue
        end
        if arr[i]-arr[i-1] != 1
            notseq = 1
        end
        if i == size(arr,1)
            break
        end
    end
    if notseq == 0
        return UnitRange(min_value,max_value)
    end
    throw(ErrorException("cannot make this into a unit range"))
end
function splatrange(range)
    return [(range)...]
end
function splatranges(ranges...)
    splattedrange = []

    for range in ranges
        splattedrange = vcat(splattedrange, splatrange(range))
    end

    return eval([Int64.(splattedrange)...])
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
function _gluearray(arr::AbstractArray)
	cparr = copy(arr)
	try
        @cast cparr[i,j] := cparr[i][j]
        @cast cparr[i,j,k,g] := cparr[i,j][k,g]
    catch
        try
            @cast cparr[i,j,k] := cparr[i][j,k]
        catch

        end
    end
    try
        @cast cparr[i,j] := cparr[i][j]
        @cast cparr[i,j,k,g] := cparr[i,j][k,g]
    catch
        try
            @cast cparr[i,j,k] := cparr[i][j,k]
        catch

        end
    end
    return cparr
end
function gluearray(arr::AbstractArray{T,N}) where {T,N}
	cparr = copy(arr)
	if T <: Vector{Vector{Vector{M}}} where M
		@cast cparr[i,j] := cparr[i][j]
		cparr = cparr |> combinedims
		return Array{Array{M},4}(cparr)
	end
	cparr = _gluearray(cparr)
	if N == 3
		try
			cparr = cparr[:,:,:]
		catch
			try
				cparr = _gluearray(cparr)
			catch
				println("shape: $(size(cparr))")
				return cparr
			end
		end
	elseif N == 4
		try
			cparr = cparr[:,:,:,:]
		catch
			try
				cparr = cparr[:,:,:]
			catch
				try
					cparr = _gluearray(cparr)
				catch
					println("shape: $(size(cparr))")
					return cparr
				end
			end
		end
	end
	return cparr
end
_g(arr::AbstractArray) =
	try
	    gluearray(arr)
	catch
		arr
	end
_v(arr::AbstractArray) = reverse(arr; dims = 1)
_h(arr::AbstractArray) = reverse(arr; dims = 2)
_t(arr::AbstractArray) = transposed(arr)
_shuffledims(arr::AbstractArray{Any,1}) = arr
_shuffledims(arr::AbstractArray{Any,2}) = @cast arr[j,i] := arr[i,j]
_shuffledims(arr::AbstractArray{Any,3}, d = 1) =
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
function _stripkeys(dict::AbstractDict)
    ks = string.(strip.(keys(dict)))
    return ks
end
_stripallkeys(dicts::AbstractArray) =  _stripkeys.(dicts)
