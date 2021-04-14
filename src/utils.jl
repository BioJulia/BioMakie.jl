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
function varcall(name::String, body::Any)
    name=Symbol(name)
    @eval (($name) = ($body))
	return Symbol(name)
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
#
function download_file(url::AbstractString, filename::AbstractString;
                       headers::Dict{String,String}=Dict{String,String}(),
                       kargs...)
    HTTP.open("GET", url, headers; kargs...) do stream
        open(filename, "w") do fh
           write(fh, stream)
        end
    end
    filename
end

function download_file(url::AbstractString;
                       headers::Dict{String,String}=Dict{String,String}(),
                       kargs...)
    download_file(url, tempname(); headers=headers, kargs...)
end
function downloadpfam(pfamcode::String; filename::String="$pfamcode.stockholm.gz", kargs...)
    @assert endswith(filename,".gz") "filename must end with the .gz extension"
    if occursin(r"^PF\d{5}$"i, pfamcode)
        number = pfamcode[3:end]
        download_file("http://pfam.xfam.org/family/PF$(number)/alignment/full/gzipped",
                      filename; kargs...)
    else
        throw(ErrorException("$pfamcode is not a correct Pfam code"))
    end
end
anynan(x) = any(isnan.(x))
dfr(x) = DataFrame(x)
dfr(xs...) = DataFrame(xs...)
indexshift(idxs, shift=1.0) = try
		float.(idxs).+=shift .|> Int
	catch
		float.(idxs).+=shift
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
function linesegs(arr::AbstractArray{AbstractFloat,3})
    new_arr::AbstractArray{Point3f0} = []
    for i in 1:size(arr,1)
        push!(new_arr, Makie.Point3f0(arr[i,1,:]))
        push!(new_arr, Makie.Point3f0(arr[i,2,:]))
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
elecolors = Dict( "C" => :gray,
                  "N" => :blue,
                  "H" => :white,
                  "O" => :red,
                  "S" => :yellow,
				  "X" => :gray,
				  "ZN" => :gray,
				  "CL" => :gray
)
aquacolors = Dict("C" => RGB{Float32}(0.5,0.5,0.5),
                  "N" => RGB{Float32}(0.472,0.211,0.499),
                  "H" => RGB{Float32}(0.65,0.96,0.70),
                  "O" => RGB{Float32}(0.111,0.37,0.999),
                  "S" => RGB{Float32}(0.992,0.753,0.525),
				  "X" => RGB{Float32}(0.5,0.5,0.5),
				  "ZN" => RGB{Float32}(0.5,0.5,0.5),
				  "CL" => RGB{Float32}(0.5,0.5,0.5)
)
kideradict = Dict(
    "A" => [-1.56,-1.67,-0.97,-0.27,-0.93,-0.78,-0.2,-0.08,0.21,-0.48],
    "R" => [0.22,1.27,1.37,1.87,-1.7,0.46,0.92,-0.39,0.23,0.93],
    "N" => [1.14,-0.07,-0.12,0.81,0.18,0.37,-0.09,1.23,1.1,-1.73],
    "D" => [0.58,-0.22,-1.58,0.81,-0.92,0.15,-1.52,0.47,0.76,0.7],
    "C" => [0.12,-0.89,0.45,-1.05,-0.71,2.41,1.52,-0.69,1.13,1.1],
    "Q" => [-0.47,0.24,0.07,1.1,1.1,0.59,0.84,-0.71,-0.03,-2.33],
    "E" => [-1.45,0.19,-1.61,1.17,-1.31,0.4,0.04,0.38,-0.35,-0.12],
    "G" => [1.46,-1.96,-0.23,-0.16,0.1,-0.11,1.32,2.36,-1.66,0.46],
    "H" => [-0.41,0.52,-0.28,0.28,1.61,1.01,-1.85,0.47,1.13,1.63],
    "I" => [-0.73,-0.16,1.79,-0.77,-0.54,0.03,-0.83,0.51,0.66,-1.78],
    "L" => [-1.04,0,-0.24,-1.1,-0.55,-2.05,0.96,-0.76,0.45,0.93],
    "K" => [-0.34,0.82,-0.23,1.7,1.54,-1.62,1.15,-0.08,-0.48,0.6],
    "M" => [-1.4,0.18,-0.42,-0.73,2,1.52,0.26,0.11,-1.27,0.27],
    "F" => [-0.21,0.98,-0.36,-1.43,0.22,-0.81,0.67,1.1,1.71,-0.44],
    "P" => [2.06,-0.33,-1.15,-0.75,0.88,-0.45,0.3,-2.3,0.74,-0.28],
    "S" => [0.81,-1.08,0.16,0.42,-0.21,-0.43,-1.89,-1.15,-0.97,-0.23],
    "T" => [0.26,-0.7,1.21,0.63,-0.1,0.21,0.24,-1.15,-0.56,0.19],
    "W" => [0.3,2.1,-0.72,-1.57,-1.16,0.57,-0.48,-0.4,-2.3,-0.6],
    "Y" => [1.38,1.48,0.8,-0.56,0,-0.68,-0.31,1.03,-0.05,0.53],
    "V" => [-0.74,-0.71,2.04,-0.4,0.5,-0.81,-1.07,0.06,-0.46,0.65],
    "B" => [0.86,-0.145,-0.85,0.81,-0.37,0.26,-0.805,0.85,0.93,-0.515],
    "Z" => [-0.96,0.215,-0.77,1.135,-0.105,0.495,0.44,-0.165,-0.19,-1.225],
    "X" => [0,0,0,0,0,0,0,0,0,0],
    "J" => [-0.885,-0.08,0.775,-0.935,-0.545,-1.01,0.065,-0.125,0.555,-0.425],
    "-" => [0,0,0,0,0,0,0,0,0,0],
    "*" => [0,0,0,0,0,0,0,0,0,0],
    "." => [0,0,0,0,0,0,0,0,0,0],
	"ALA" => [-1.56,-1.67,-0.97,-0.27,-0.93,-0.78,-0.2,-0.08,0.21,-0.48],
    "ARG" => [0.22,1.27,1.37,1.87,-1.7,0.46,0.92,-0.39,0.23,0.93],
    "ASN" => [1.14,-0.07,-0.12,0.81,0.18,0.37,-0.09,1.23,1.1,-1.73],
    "ASP" => [0.58,-0.22,-1.58,0.81,-0.92,0.15,-1.52,0.47,0.76,0.7],
    "CYS" => [0.12,-0.89,0.45,-1.05,-0.71,2.41,1.52,-0.69,1.13,1.1],
    "GLN" => [-0.47,0.24,0.07,1.1,1.1,0.59,0.84,-0.71,-0.03,-2.33],
    "GLU" => [-1.45,0.19,-1.61,1.17,-1.31,0.4,0.04,0.38,-0.35,-0.12],
    "GLY" => [1.46,-1.96,-0.23,-0.16,0.1,-0.11,1.32,2.36,-1.66,0.46],
    "HIS" => [-0.41,0.52,-0.28,0.28,1.61,1.01,-1.85,0.47,1.13,1.63],
    "ILE" => [-0.73,-0.16,1.79,-0.77,-0.54,0.03,-0.83,0.51,0.66,-1.78],
    "LEU" => [-1.04,0,-0.24,-1.1,-0.55,-2.05,0.96,-0.76,0.45,0.93],
    "LYS" => [-0.34,0.82,-0.23,1.7,1.54,-1.62,1.15,-0.08,-0.48,0.6],
    "MET" => [-1.4,0.18,-0.42,-0.73,2,1.52,0.26,0.11,-1.27,0.27],
    "PHE" => [-0.21,0.98,-0.36,-1.43,0.22,-0.81,0.67,1.1,1.71,-0.44],
    "PRO" => [2.06,-0.33,-1.15,-0.75,0.88,-0.45,0.3,-2.3,0.74,-0.28],
    "SER" => [0.81,-1.08,0.16,0.42,-0.21,-0.43,-1.89,-1.15,-0.97,-0.23],
    "THR" => [0.26,-0.7,1.21,0.63,-0.1,0.21,0.24,-1.15,-0.56,0.19],
    "TRP" => [0.3,2.1,-0.72,-1.57,-1.16,0.57,-0.48,-0.4,-2.3,-0.6],
    "TYR" => [1.38,1.48,0.8,-0.56,0,-0.68,-0.31,1.03,-0.05,0.53],
    "VAL" => [-0.74,-0.71,2.04,-0.4,0.5,-0.81,-1.07,0.06,-0.46,0.65],
    "ASX" => [0.86,-0.145,-0.85,0.81,-0.37,0.26,-0.805,0.85,0.93,-0.515],
    "GLX" => [-0.96,0.215,-0.77,1.135,-0.105,0.495,0.44,-0.165,-0.19,-1.225],
    "XAA" => [0,0,0,0,0,0,0,0,0,0],
    "XLE" => [-0.885,-0.08,0.775,-0.935,-0.545,-1.01,0.065,-0.125,0.555,-0.425] )
kdict2 = Dict(
    "A" => [-1.67],
    "R" => [1.27],
    "N" => [-0.07],
    "D" => [-0.22],
    "C" => [-0.89],
    "Q" => [0.24],
    "E" => [0.19],
    "G" => [-1.96],
    "H" => [0.52],
    "I" => [-0.16],
    "L" => [0],
    "K" => [0.82],
    "M" => [0.18],
    "F" => [0.98],
    "P" => [-0.33],
    "S" => [-1.08],
    "T" => [-0.7],
    "W" => [2.1],
    "Y" => [1.48],
    "V" => [-0.71],
    "B" => [-0.145],
    "Z" => [0.215],
    "X" => [0],
    "J" => [-0.08],
    "-" => [0],
    "*" => [0],
    "." => [0],
	"ALA" => [-1.67],
    "ARG" => [1.27],
    "ASN" => [-0.07],
    "ASP" => [-0.22],
    "CYS" => [-0.89],
    "GLN" => [0.24],
    "GLU" => [0.19],
    "GLY" => [-1.96],
    "HIS" => [0.52],
    "ILE" => [-0.16],
    "LEU" => [0],
    "LYS" => [0.82],
    "MET" => [0.18],
    "PHE" => [0.98],
    "PRO" => [-0.33],
    "SER" => [-1.08],
    "THR" => [-0.7],
    "TRP" => [2.1],
    "TYR" => [1.48],
    "VAL" => [-0.71],
    "ASX" => [-0.145],
    "GLX" => [0.215],
    "XAA" => [0],
    "XLE" => [-0.08] )
#
# import Base: length, getindex, setindex!, size, copy, deepcopy, empty!,
#              convert, transpose, ctranspose, names

"""
MIToS MSA and aligned sequences (aligned objects) are subtypes of `AbstractMatrix{Residue}`,
because MSAs and sequences are stored as `Matrix` of `Residue`s.
"""
abstract type AbstractAlignedObject <: AbstractMatrix{Residue} end

"""
MSAs are stored as `Matrix{Residue}`. It's possible to use a
`NamedResidueMatrix{Array{Residue,2}}` as the most simple MSA with sequence
identifiers and column names.
"""
abstract type AbstractMultipleSequenceAlignment <: AbstractAlignedObject end

"A MIToS aligned sequence is an `AbstractMatrix{Residue}` with only 1 row/sequence."
abstract type AbstractAlignedSequence <: AbstractAlignedObject end

# Multiple Sequence Alignment
# ===========================
using NamedArrays
const NamedResidueMatrix{AT} = NamedArray{Residue,
                                         2,
                                         AT,
                                         Tuple{OrderedDict{String,Int},
                                               OrderedDict{String,Int}}}

"""
This MSA type include a `NamedArray` wrapping a `Matrix` of `Residue`s. The use of
`NamedArray` allows to store sequence names and original column numbers as `String`s, and
fast indexing using them.
"""
mutable struct MultipleSequenceAlignment <: AbstractMultipleSequenceAlignment
    matrix::NamedResidueMatrix{Array{Residue,2}}

    function (::Type{MultipleSequenceAlignment})(matrix::NamedResidueMatrix{Array{Residue,2}})
        setdimnames!(matrix,("Seq","Col"))
        new(matrix)
    end
end

"""
This type represent an MSA, similar to `MultipleSequenceAlignment`, but It also stores
`Annotations`. This annotations are used to store residue coordinates (i.e. mapping
to UniProt residue numbers).
"""
mutable struct AnnotatedMultipleSequenceAlignment <: AbstractMultipleSequenceAlignment
    matrix::NamedArray{ Residue, 2, Array{Residue, 2},
                        Tuple{OrderedDict{String, Int},
                        OrderedDict{String, Int}} }
    annotations::Annotations

    function (::Type{AnnotatedMultipleSequenceAlignment})(matrix::NamedResidueMatrix{Array{Residue,2}},
                                                          annotations::Annotations)
        setdimnames!(matrix,("Seq","Col"))
        new(matrix, annotations)
    end
end

# Aligned Sequences
# -----------------

"""
An `AlignedSequence` wraps a `NamedResidueMatrix{Array{Residue,2}}` with only 1 row/sequence. The
`NamedArray` stores the sequence name and original column numbers as `String`s.
"""
mutable struct AlignedSequence <: AbstractAlignedSequence
    matrix::NamedResidueMatrix{Array{Residue,2}}

    function (::Type{AlignedSequence})(matrix::NamedResidueMatrix{Array{Residue,2}})
        @assert size(matrix,1) == 1 "There are more than one sequence."
        setdimnames!(matrix,("Seq","Col"))
        new(matrix)
    end
end

"""
This type represent an aligned sequence, similar to `AlignedSequence`, but It also stores
its `Annotations`.
"""
mutable struct AnnotatedAlignedSequence <: AbstractAlignedSequence
    matrix::NamedResidueMatrix{Array{Residue,2}}
    annotations::Annotations

    function (::Type{AnnotatedAlignedSequence})(matrix::NamedResidueMatrix{Array{Residue,2}},
                                                annotations::Annotations)
        @assert size(matrix,1) == 1 "There are more than one sequence."
        setdimnames!(matrix,("Seq","Col"))
        new(matrix, annotations)
    end
end

# Constructors
# ------------

function AnnotatedMultipleSequenceAlignment(msa::NamedResidueMatrix{Array{Residue,2}})
    AnnotatedMultipleSequenceAlignment(msa, Annotations())
end

function AnnotatedMultipleSequenceAlignment(msa::Matrix{Residue})
    AnnotatedMultipleSequenceAlignment(NamedArray(msa))
end

function AnnotatedMultipleSequenceAlignment(msa::AbstractMatrix{Residue})
    AnnotatedMultipleSequenceAlignment(convert(Matrix{Residue}, msa))
end

function MultipleSequenceAlignment(msa::Matrix{Residue})
    MultipleSequenceAlignment(NamedArray(msa))
end

function MultipleSequenceAlignment(msa::AbstractMatrix{Residue})
    MultipleSequenceAlignment(convert(Matrix{Residue}, msa))
end

function AnnotatedAlignedSequence(seq::NamedResidueMatrix{Array{Residue,2}})
    AnnotatedAlignedSequence(seq, Annotations())
end

function AnnotatedAlignedSequence(seq::Matrix{Residue})
    AnnotatedAlignedSequence(NamedArray(seq))
end

function AnnotatedAlignedSequence(seq::AbstractMatrix{Residue})
    AnnotatedAlignedSequence(convert(Matrix{Residue}, seq))
end

function AlignedSequence(seq::Matrix{Residue})
    AlignedSequence(NamedArray(seq))
end

function AlignedSequence(seq::AbstractMatrix{Residue})
    AlignedSequence(convert(Matrix{Residue}, seq))
end

# AnnotatedAlignedObject
# ----------------------

const AnnotatedAlignedObject = Union{ AnnotatedMultipleSequenceAlignment,
                                      AnnotatedAlignedSequence    }

const UnannotatedAlignedObject = Union{ MultipleSequenceAlignment,
                                        AlignedSequence    }

# Matrices
# --------

const MSAMatrix = Union{ Matrix{Residue}, NamedResidueMatrix{Array{Residue,2}} }

# Getters
# -------

"`annotations` returns the `Annotations` of an MSA or aligned sequence."
@inline annotations(msa::AnnotatedMultipleSequenceAlignment) = msa.annotations
@inline annotations(seq::AnnotatedAlignedSequence) = seq.annotations

"`namedmatrix` returns the `NamedResidueMatrix{Array{Residue,2}}` stored in an MSA or aligned sequence."
@inline namedmatrix(x::AbstractAlignedObject) = x.matrix

# Convert
# -------

function Base.convert(::Type{MultipleSequenceAlignment},
                      msa::AnnotatedMultipleSequenceAlignment)
    MultipleSequenceAlignment(namedmatrix(msa))
end

function Base.convert(::Type{AlignedSequence}, seq::AnnotatedAlignedSequence)
    AlignedSequence(namedmatrix(seq))
end

function Base.convert(::Type{AnnotatedMultipleSequenceAlignment},
                      msa::MultipleSequenceAlignment)
    AnnotatedMultipleSequenceAlignment(namedmatrix(msa), Annotations())
end

function Base.convert(::Type{AnnotatedAlignedSequence}, seq::AlignedSequence)
    AnnotatedAlignedSequence(namedmatrix(seq), Annotations())
end

# AbstractArray Interface
# -----------------------

for f in (:size, :length)
    @eval Base.$(f)(x::AbstractAlignedObject) = $(f)(namedmatrix(x))
end

for T in (  :(AlignedSequence),
            :(AnnotatedAlignedSequence),
            :(MultipleSequenceAlignment),
            :(AnnotatedMultipleSequenceAlignment)  )
    @eval Base.IndexStyle(::Type{$(T)}) = Base.IndexLinear()
end

@inline Base.getindex(x::AbstractAlignedObject,
                      args...) = getindex(namedmatrix(x), args...)

@inline function Base.setindex!(x::AbstractAlignedObject, value, args...)
    setindex!(namedmatrix(x), value, args...)
end

# Special getindex/setindex! for sequences to avoid `seq["seqname","colname"]`

@inline function Base.getindex(x::AbstractAlignedSequence,
                               i::Union{Int, AbstractString})
    getindex(namedmatrix(x), 1, i)
end

@inline function Base.setindex!(x::AbstractAlignedSequence, value,
                                i::Union{Int, AbstractString})
    setindex!(namedmatrix(x), value, 1, i)
end

# Show
# ----

for T in (  :(AlignedSequence),
            :(AnnotatedAlignedSequence),
            :(MultipleSequenceAlignment),
            :(AnnotatedMultipleSequenceAlignment)  )
    @eval begin

        Base.show(io::IO, ::MIME"text/plain", x::$(T)) = show(io, x)

        function Base.show(io::IO, x::$(T))
            type_name = split(string($T),'.')[end]
            if isa(x, AnnotatedAlignedObject)
                print(io, type_name, " with ", length(annotations(x)), " annotations : ")
            else
                print(io, type_name, " : ")
            end
            show(io, namedmatrix(x))
        end

    end
end

# Transpose
# ---------

Base.transpose(x::AbstractAlignedObject)  = transpose(namedmatrix(x))
Base.permutedims(x::AbstractAlignedObject, args...) = permutedims(namedmatrix(x), args...)

# Selection without Mappings
# --------------------------

"""
`getresidues` allows you to access the residues stored inside an MSA or aligned sequence
as a `Matrix{Residue}` without annotations nor column/row names.
"""
getresidues(x::Matrix{Residue}) = x
getresidues(x::NamedResidueMatrix{Array{Residue,2}}) = getarray(x)
getresidues(x::AbstractAlignedObject) = getresidues(namedmatrix(x))

"`nsequences` returns the number of sequences on the MSA."
nsequences(x::AbstractMatrix{Residue}) = size(x, 1)

"`ncolumns` returns the number of MSA columns or positions."
ncolumns(x::AbstractMatrix{Residue}) = size(x, 2)

"""
`getresiduesequences` returns a `Vector{Vector{Residue}}` with all the MSA sequences without
annotations nor column/sequence names.
"""
function getresiduesequences(msa::Matrix{Residue})
    nseq = nsequences(msa)
    tmsa = permutedims(msa, [2,1])
    sequences = Array{Vector{Residue}}(undef, nseq)
    for i in 1:nseq
        @inbounds sequences[i] = tmsa[:,i]
    end
    sequences
end

getresiduesequences(x::NamedResidueMatrix{Array{Residue,2}}) = getresiduesequences(getresidues(x))
getresiduesequences(x::AbstractAlignedObject) = getresiduesequences(getresidues(x))

# Select sequence
# ---------------

# Gives you the annotations of the Sequence
function getsequence(data::Annotations, id::String)
    GS = Dict{Tuple{String,String},String}()
    GR = Dict{Tuple{String,String},String}()
    if length(data.sequences) > 0
        for (key, value) in data.sequences
            if key[1] == id
                GS[key] = value
            end
        end
        sizehint!(GS, length(GS))
    end
    if length(data.residues) > 0
        for (key, value) in data.residues
            if key[1] == id
                GR[key] = value
            end
        end
        sizehint!(GR, length(GR))
    end
    Annotations(data.file, GS, data.columns, GR)
end

@doc """
`getsequence` takes an MSA and a sequence number or identifier and returns an aligned
sequence object. If the MSA is an `AnnotatedMultipleSequenceAlignment`, it returns an
`AnnotatedAlignedSequence` with the sequence annotations. From a
`MultipleSequenceAlignment`, It returns an `AlignedSequence` object. If an `Annotations`
object and a sequence identifier are used, this function returns the annotations related
to the sequence.
""" getsequence

getsequence(msa::AbstractMatrix{Residue}, i::Int) = msa[i:i,:]

getsequence(msa::NamedResidueMatrix{Array{Residue,2}}, i::Int) = msa[i:i,:]
getsequence(msa::NamedResidueMatrix{Array{Residue,2}}, id::String) = msa[String[id],:]

function getsequence(msa::AnnotatedMultipleSequenceAlignment, i::Int)
    seq   = namedmatrix(msa)[i:i,:]
    annot = getsequence(annotations(msa), names(seq, 1)[1])
    AnnotatedAlignedSequence(seq, annot)
end

function getsequence(msa::AnnotatedMultipleSequenceAlignment, id::String)
    seq   = namedmatrix(msa)[String[id],:]
    annot = getsequence(annotations(msa), id)
    AnnotatedAlignedSequence(seq, annot)
end

function getsequence(msa::MultipleSequenceAlignment, seq::String)
    AlignedSequence(getsequence(namedmatrix(msa), seq))
end

function getsequence(msa::MultipleSequenceAlignment, seq::Int)
    AlignedSequence(getsequence(namedmatrix(msa), seq))
end

# Names
# -----

"""
`sequencenames(msa)`

It returns a `Vector{String}` with the sequence names/identifiers.
"""
function sequencenames(x::NamedResidueMatrix{AT})::Vector{String} where AT <: AbstractArray
    names(x,1)
end
sequencenames(x::AbstractAlignedObject)::Vector{String} = sequencenames(namedmatrix(x))
sequencenames(msa::AbstractMatrix{Residue})::Vector{String} = map(string, 1:size(msa,1))

"""
`columnnames(msa)`

It returns a `Vector{String}` with the sequence names/identifiers. If the `msa` is a
`Matrix{Residue}` this function returns the actual column numbers as strings. Otherwise it
returns the column number of the original MSA through the wrapped `NamedArray` column names.
"""
function columnnames(x::NamedResidueMatrix{AT})::Vector{String} where AT
    names(x,2)
end
columnnames(x::AbstractAlignedObject)::Vector{String} = columnnames(namedmatrix(x))
columnnames(msa::AbstractMatrix{Residue})::Vector{String} = map(string, 1:size(msa,2))

# Copy, deepcopy
# --------------

for f in (:copy, :deepcopy)
    @eval begin
        function Base.$(f)(msa::AnnotatedMultipleSequenceAlignment)
            AnnotatedMultipleSequenceAlignment( $(f)(namedmatrix(msa)),
                                                $(f)(annotations(msa)) )
        end
        function Base.$(f)(msa::MultipleSequenceAlignment)
            MultipleSequenceAlignment($(f)(namedmatrix(msa)))
        end
        function Base.$(f)(seq::AnnotatedAlignedSequence)
            AnnotatedAlignedSequence($(f)(seq.matrix), $(f)(seq.annotations))
        end
        Base.$(f)(seq::AlignedSequence) = AlignedSequence($(f)(seq.matrix))
    end
end

# Get annotations
# ---------------

for getter in ( :getannotcolumn, :getannotfile, :getannotresidue, :getannotsequence )
    @eval $(getter)(x::AnnotatedAlignedObject, args...) = $(getter)(annotations(x), args...)
end

# Set annotations
# ---------------

for setter in ( :setannotcolumn!, :setannotfile!, :setannotresidue!, :setannotsequence!,
                :annotate_modification!,
                :delete_annotated_modifications!,
                :printmodifications )
    @eval $(setter)(x::AnnotatedAlignedObject, args...) = $(setter)(annotations(x), args...)
end

# To be used on AbstractMultipleSequenceAlignment methods
@inline function annotate_modification!(msa::MultipleSequenceAlignment, str::String)
    # It's generally used in a boolean context: annotate && annotate_modification!(...
    false
end

# Mapping annotations
# ===================

"""
Converts a string of mappings into a vector of `Int`s

```jldoctest
julia> using MIToS.MSA

julia> MSA._str2int_mapping(",,2,,4,5")
6-element Array{Int64,1}:
 0
 0
 2
 0
 4
 5

```
"""
function _str2int_mapping(mapping::String)
    values = split(mapping, ',')
    len = length(values)
    intmap = Array{Int}(undef, len)
    @inbounds for i in 1:len
        value = values[i]
        intmap[i] = value == "" ? 0 : parse(Int, value)
    end
    intmap
end

"""
It returns a `Vector{Int}` with the original column number of each column on the actual MSA.
The mapping is annotated in the "ColMap" file annotation of an
`AnnotatedMultipleSequenceAlignment` or in the column names of an `NamedArray` or
`MultipleSequenceAlignment`.
"""
function getcolumnmapping(msa::AnnotatedMultipleSequenceAlignment)
    annot = getannotfile(msa)
    if haskey(annot, "ColMap")
        return _str2int_mapping(annot["ColMap"])
    else
        return getcolumnmapping(namedmatrix(msa))
    end
end

function getcolumnmapping(msa::NamedResidueMatrix{AT}) where AT <: AbstractMatrix
    Int[ parse(Int,pos) for pos in names(msa,2) ]
end

getcolumnmapping(msa::MultipleSequenceAlignment) = getcolumnmapping(namedmatrix(msa))

"""
It returns the sequence coordinates as a `Vector{Int}` for an MSA sequence. That vector has
one element for each MSA column. If the number if `0` in the mapping, there is a gap in
that column for that sequence.
"""
function getsequencemapping(msa::AnnotatedMultipleSequenceAlignment, seq_id::String)
    _str2int_mapping(getannotsequence(msa, seq_id, "SeqMap"))
end

function getsequencemapping(msa::AnnotatedMultipleSequenceAlignment, seq_num::Int)
    getsequencemapping(msa, sequencenames(msa)[seq_num])
end

# Sequences as strings
# --------------------

"""
```
stringsequence(seq)
stringsequence(msa, i::Int)
stringsequence(msa, id::String)
```

It returns the selected sequence as a `String`.
"""
stringsequence(msa::AbstractMatrix{Residue}, i) = String(vec(msa[i,:]))

function stringsequence(msa::AbstractMultipleSequenceAlignment, i)
    stringsequence(namedmatrix(msa), i)
end

function stringsequence(seq::AbstractMatrix{Residue})
    @assert size(seq,1) == 1 "There are more than one sequence/row."
    String(vec(seq))
end

stringsequence(seq::AbstractAlignedSequence) = stringsequence(namedmatrix(seq))

#
import Base: read

"`FileFormat` is used for write special `parse` (and `read`) methods on it."
abstract type FileFormat end

"""
`download_file` uses **HTTP.jl** instead of system calls to download files
from the web. It takes the file url as first argument and, optionally, a path to save it.
Keyword arguments (ie. `redirect`, `retry`, `readtimeout`)
are are directly passed to to `HTTP.open` (`HTTP.request`).
Use the `headers` keyword argument to pass a `Dict{String,String}` with the
header information.
```jldoctest
julia> using MIToS.Utils
julia> download_file("http://www.uniprot.org/uniprot/P69905.fasta","seq.fasta",
       headers = Dict("User-Agent" =>
                      "Mozilla/5.0 (compatible; MSIE 7.01; Windows NT 5.0)"),
       redirect=true)
"seq.fasta"
```
"""
function download_file(url::AbstractString, filename::AbstractString;
                       headers::Dict{String,String}=Dict{String,String}(),
                       kargs...)
    HTTP.open("GET", url, headers; kargs...) do stream
        open(filename, "w") do fh
           write(fh, stream)
        end
    end
    filename
end

function download_file(url::AbstractString;
                       headers::Dict{String,String}=Dict{String,String}(),
                       kargs...)
    download_file(url, tempname(); headers=headers, kargs...)
end

"Create an iterable object that will yield each line from a stream **or string**."
lineiterator(string::String) = eachline(IOBuffer(string))
lineiterator(stream::IO)     = eachline(stream)

"""
Returns the `filename`.
Throws an `ErrorException` if the file doesn't exist, or a warning if the file is empty.
"""
function check_file(filename)
    if !isfile(filename)
        throw(ErrorException(string(filename, " doesn't exist!")))
    elseif filesize(filename) == 0
        @warn string(filename, " is empty!")
    end
    filename
end

"Returns `true` if the file exists and isn't empty."
isnotemptyfile(filename) = isfile(filename) && filesize(filename) > 0

# for using with download, since filename doesn't have file extension
function _read(completename::AbstractString,
               filename::AbstractString,
               format::Type{T},
               args...; kargs...) where T <: FileFormat
    check_file(filename)
    if endswith(completename, ".xml.gz") || endswith(completename, ".xml")
        document = parse_file(filename)
        try
            parse(document, T, args...; kargs...)
        finally
            free(document)
        end
    else
        fh = open(filename, "r")
        try
            fh = endswith(completename, ".gz") ? GzipDecompressorStream(fh) : fh
            parse(fh, T, args...; kargs...)
        finally
            close(fh)
        end
    end
end

"""
`read(pathname, FileFormat [, Type [, … ] ] ) -> Type`
This function opens a file in the `pathname` and calls `parse(io, ...)` for
the given `FileFormat` and `Type` on it. If the  `pathname` is an HTTP or FTP URL,
the file is downloaded with `download` in a temporal file.
Gzipped files should end on `.gz`.
"""
function read(completename::AbstractString,
              format::Type{T},
              args...; kargs...) where T <: FileFormat
    if  startswith(completename, "http://")  ||
        startswith(completename, "https://") ||
        startswith(completename, "ftp://")

        filename = download_file(completename)
        try
            _read(completename, filename, T, args...; kargs...)
        finally
            rm(filename)
        end
    else
        # completename and filename are the same
        _read(completename, completename, T, args...; kargs...)
    end
end
struct Stockholm <: FileFormat end

@inline function _fill_with_sequence_line!(IDS, SEQS, line)
    if !startswith(line,'#') && !startswith(line,"//")
        words = get_n_words(line, 2)
        @inbounds id = words[1]
        if id in IDS
            # It's useful when sequences are split into several lines
            # It can be a problem with duplicated IDs
            i = something(findfirst(isequal(id), IDS), 0)
            SEQS[i] = SEQS[i] * words[2]
        else
            push!(IDS, id)
            push!(SEQS, words[2])
        end
    end
end

function _fill_with_line!(IDS, SEQS, GF, GS, GC, GR, line)
    if startswith(line,"#=GF")
        words = get_n_words(line, 3)
        id = words[2]
        if id in keys(GF)
            GF[ id ] = GF[ id ] * "\n" * words[3]
        else
            GF[ id ] = words[3]
        end
    elseif startswith(line,"#=GS")
        words = get_n_words(line, 4)
        idtuple = (words[2],words[3])
        if idtuple in keys(GS)
            GS[ idtuple ] = GS[ idtuple ] * "\n" * words[4]
        else
            GS[ idtuple ] = words[4]
        end
    elseif startswith(line,"#=GC")
        words = get_n_words(line, 3)
        GC[words[2]] = words[3]
    elseif startswith(line,"#=GR")
        words = get_n_words(line, 4)
        GR[(words[2],words[3])] = words[4]
    else
        _fill_with_sequence_line!(IDS, SEQS, line)
    end
end

function _pre_readstockholm(io::Union{IO, AbstractString})
    IDS  = OrderedSet{String}()
    SEQS = String[]
    GF = OrderedDict{String,String}()
    GC = Dict{String,String}()
    GS = Dict{Tuple{String,String},String}()
    GR = Dict{Tuple{String,String},String}()

    @inbounds for line::String in lineiterator(io)
        _fill_with_line!(IDS, SEQS, GF, GS, GC, GR, line)
        if startswith(line, "//")
           break
        end
    end

    _check_seq_len(IDS, SEQS)

    GF = sizehint!(GF, length(GF))
    GC = sizehint!(GC, length(GC))
    GS = sizehint!(GS, length(GS))
    GR = sizehint!(GR, length(GR))
    (IDS, SEQS, GF, GS, GC, GR)
end

function _pre_readstockholm_sequences(io::Union{IO, AbstractString})
    IDS  = OrderedSet{String}()
    SEQS = String[]
    @inbounds for line::String in lineiterator(io)
        _fill_with_sequence_line!(IDS, SEQS, line)
        if startswith(line, "//")
           break
        end
    end
    _check_seq_len(IDS, SEQS)
    (IDS, SEQS)
end

function Base.parse(io::Union{IO, AbstractString},
                   format::Type{Stockholm},
                   output::Type{AnnotatedMultipleSequenceAlignment};
                   generatemapping::Bool=false,
                   useidcoordinates::Bool=false,
                   deletefullgaps::Bool=true,
                   keepinserts::Bool=false)::AnnotatedMultipleSequenceAlignment
    IDS, SEQS, GF, GS, GC, GR = _pre_readstockholm(io)
    annot = Annotations(GF, GS, GC, GR)
    _generate_annotated_msa(annot, collect(IDS), SEQS, keepinserts,
                            generatemapping, useidcoordinates, deletefullgaps)
end

function Base.parse(io::Union{IO, AbstractString},
                   format::Type{Stockholm},
                   output::Type{NamedResidueMatrix{Array{Residue,2}}};
                   deletefullgaps::Bool=true)::NamedResidueMatrix{Array{Residue,2}}
    IDS, SEQS = _pre_readstockholm_sequences(io)
    msa = _generate_named_array(SEQS, IDS)
    if deletefullgaps
        return deletefullgapcolumns(msa)
    end
    msa
end

function Base.parse(io::Union{IO, AbstractString},
                   format::Type{Stockholm},
                   output::Type{MultipleSequenceAlignment};
                   deletefullgaps::Bool=true)::MultipleSequenceAlignment
    msa = parse(io,
                format,
                NamedResidueMatrix{Array{Residue,2}},
                deletefullgaps=deletefullgaps)
    MultipleSequenceAlignment(msa)
end

function Base.parse(io::Union{IO,AbstractString},
                   format::Type{Stockholm},
                   output::Type{Matrix{Residue}};
                   deletefullgaps::Bool=true)::Matrix{Residue}
    IDS, SEQS = _pre_readstockholm_sequences(io)
    _strings_to_matrix_residue_unsafe(SEQS, deletefullgaps)
end

function Base.parse(io, format::Type{Stockholm};
                    generatemapping::Bool=false,
                    useidcoordinates::Bool=false,
                    deletefullgaps::Bool=true,
                    keepinserts::Bool=false)::AnnotatedMultipleSequenceAlignment
    parse(io, Stockholm, AnnotatedMultipleSequenceAlignment,
          generatemapping=generatemapping,
          useidcoordinates=useidcoordinates,
          deletefullgaps=deletefullgaps,
          keepinserts=keepinserts)
end

# Print Pfam
# ==========

function _to_sequence_dict(annotation::Dict{Tuple{String,String},String})
    seq_dict = Dict{String,Vector{String}}()
    for (key, value) in annotation
        seq_id = key[1]
        if haskey(seq_dict, seq_id)
            push!(seq_dict[seq_id], string(seq_id, '\t', key[2], '\t', value))
        else
            seq_dict[seq_id] = [ string(seq_id, '\t', key[2], '\t', value) ]
        end
    end
    sizehint!(seq_dict, length(seq_dict))
end

function Base.print(io::IO, msa::AnnotatedMultipleSequenceAlignment,
                    format::Type{Stockholm})
    _printfileannotations(io, msa.annotations)
    _printsequencesannotations(io, msa.annotations)
    res_annotations = _to_sequence_dict(msa.annotations.residues)
    seqnames = sequencenames(msa)
    for i in 1:nsequences(msa)
        id = seqnames[i]
        seq = stringsequence(msa, i)
        println(io, id, "\t\t\t", seq)
        if id in keys(res_annotations)
            for line in res_annotations[id]
                println(io, "#=GR ", line)
            end
        end
    end
    _printcolumnsannotations(io, msa.annotations)
    println(io, "//")
end

function Base.print(io::IO, msa::AbstractMatrix{Residue}, format::Type{Stockholm})
    seqnames = sequencenames(msa)
    for i in 1:nsequences(msa)
        println(io, seqnames[i], "\t\t\t", stringsequence(msa, i))
    end
    println(io, "//")
end

Base.print(msa::AnnotatedMultipleSequenceAlignment) = print(stdout, msa, Stockholm)
