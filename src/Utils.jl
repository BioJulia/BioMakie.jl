GLFW.WindowHint(GLFW.FLOATING, 1)
hbox(xs...) = Makie.hbox(xs...)
vbox(xs...) = Makie.vbox(xs...)
res3letters = ["ARG", "MET", "ASN", "GLU", "PHE",
	"ILE", "ASP", "LEU", "ALA", "GLN",
	"GLY", "CYS", "TRP", "TYR", "LYS",
	"PRO", "THR", "SER", "VAL", "HIS",
	"ASX", "GLX", "XAA", "XLE", "-", ".", "*"]
resletters = ["R", "M", "N", "E", "F",
	"I", "D", "L", "A", "Q",
	"G", "C", "W", "Y", "K",
	"P", "T", "S", "V", "H",
	"B", "Z", "X", "J", "-", ".", "*"]
atomicmasses = Dict("C" => 12.0107,
                    "N" => 14.0067,
                    "H" => 1.0079,
                    "O" => 15.9994,
                    "S" => 32.065,
					"X" => 1.0079
)
vanderwaals = Dict( "C" => 1.70,
            "N" => 1.55,
            "H" => 1.20,
            "O" => 1.52,
            "S" => 1.85,
			"X" => 1.20
)
elecolors = Dict( "C" => :darkgreen,
                  "N" => :blue,
                  "H" => :white,
                  "O" => :red,
                  "S" => :yellow,
				  "X" => :gray
)
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
function gluearray(arr::AbstractArray{T,N}) where {T,N}
	temparr = copy(arr)
	if T <: Vector{M} where M
		return @cast temparr[i,j] := temparr[i][j]
	elseif T <: Vector{Vector{Vector{M}}} where M
		@cast temparr[i,j] := temparr[i][j]
		temparr = temparr |> combinedims
		return Array{Array{M},4}(temparr)
	end
	temparr = gluearray(temparr)
	if N == 3
		try
			temparr = temparr[:,:,:]
		catch
			@show temparr
		end
	elseif N == 4
		try
			temparr = temparr[:,:,:,:]
		catch
			try
				temparr = temparr[:,:,:]
			catch
				@show temparr
			end
		end
	end
	return temparr
end
function gluearray2(arr::AbstractArray)
	temparr = copy(arr)
	try
        @cast temparr[i,j] := temparr[i][j]
        @cast temparr[i,j,k,g] := temparr[i,j][k,g]
    catch
        try
            @cast temparr[i,j,k] := temparr[i][j,k]
        catch

        end
    end
    try
        @cast temparr[i,j] := temparr[i][j]
        @cast temparr[i,j,k,g] := temparr[i,j][k,g]
    catch
        try
            @cast temparr[i,j,k] := temparr[i][j,k]
        catch

        end
    end
    return temparr
end
_g(arr::AbstractArray) = try
	    gluearray(arr)
	catch
	    try
	        gluearray2(arr)
	    catch
			arr
	    end
end
function gluearray!(arr::AbstractArray{T,N}) where {T,N}
	if T <: Vector{M} where M
		return @cast arr[i,j] := arr[i][j]
	elseif T <: Vector{Vector{Vector{M}}} where M
		@cast arr[i,j] := arr[i][j]
		arr = arr |> combinedims
		return Array{Array{M},4}(arr)
	end
	arr = gluearray!(arr)
	if N == 3
		try
			arr = arr[:,:,:]
		catch
			@show arr
		end
	elseif N == 4
		try
			arr = arr[:,:,:,:]
		catch
			try
				arr = arr[:,:,:]
			catch
				@show arr
			end
		end
	end
	return arr
end
function gluearray2!(arr::AbstractArray)
    try
        @cast arr[i,j] := arr[i][j]
        @cast arr[i,j,k,g] := arr[i,j][k,g]
    catch
        try
            @cast arr[i,j,k] := arr[i][j,k]
        catch

        end
    end
    try
        @cast arr[i,j] := arr[i][j]
        @cast arr[i,j,k,g] := arr[i,j][k,g]
    catch
        try
            @cast arr[i,j,k] := arr[i][j,k]
        catch

        end
    end
    return arr
end
_g!(arr::AbstractArray) = try
	    gluearray!(arr)
	catch
	    try
	        gluearray2!(arr)
	    catch

	    end
end
