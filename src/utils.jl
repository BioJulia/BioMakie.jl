export protsmiles,
    elecolors,
    cpkcolors, 
    aquacolors, 
    shapelycolors, 
    leskcolors, 
    maecolors, 
    cinemacolors,
    getbiocolors

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
function reversekv(dict::AbstractDict{K,V}) where {K,V}
	vkdict = [x[2].=>x[1] for x in dict]
    if typeof(dict) <: OrderedDict
        return OrderedDict{V,K}(vkdict)
    end
	return Dict{V,K}(vkdict)
end
function collectkeys(args)
    return keys(args) |> collect
end
function collectvals(args)
    return values(args) |> collect
end
function printkv(dict::AbstractDict)
	keys1 = collectkeys(dict)
	vals1 = collectvals(dict)
	println.(["$(keys1[i]) -> $(vals1[i])" for i in 1:size(keys1,1)])
	return nothing
end
typefields(thing) = typeof(thing) |> fieldnames
tyf(thing) = typefields(thing)
function parseint(num)
    return parse(Int64, num)
end
function parsefloat(num)
    return parse(Float64, num)
end
function parsefloat32(num)
    return parse(Float32, num)
end
function transposed(mat::AbstractMatrix)
    mat2 = mat
    @cast mat2[i,j] := mat[j,i]
    mat2 = mat2[:,:] .|> identity
    return mat2
end
_t(arr::AbstractArray) = transposed(arr)
_v(arr::AbstractArray) = reverse(arr; dims = 1)
_h(arr::AbstractArray) = reverse(arr; dims = 2)
macro trycatch(ex)
    quote
        try
            $(esc(ex))
        catch
            # do nothing
        end
    end
end
function varcall(name::String, body::Any)
    name=Symbol(name)
    @eval (($name) = ($body))
	return Symbol(name)
end

# current basic color schemes for atoms and residues
elecolors = Dict( "C" => :gray,
                  "N" => :blue,
                  "H" => :white,
                  "O" => :red,
                  "S" => :yellow,
				  "ZN" => :gray,
				  "CL" => :gray,
                  "X" => :gray
)
cpkcolors = Dict( "C" => RGB(200.0,200.0,200.0),
                  "N" => RGB(143.0,143.0,255.0),
                  "H" => RGB(255.0,255.0,255.0),
                  "O" => RGB(240.0,0.0,0.0),
                  "S" => RGB(255.0,200.0,50.0),
                  "P" => RGB(255.0,165.0,0.0),
                  "CL" => RGB(0.0,255.0,0.0),
                  "BR" => RGB(165.0,42.0,42.0),
				  "ZN" => RGB(165.0,42.0,42.0),
                  "NA" => RGB(0.0,0.0,255.0),
                  "FE" => RGB(255.0,165.0,0.0),
                  "CA" => RGB(128.0,128.0,144.0),
                  "X" => RGB(255.0,20.0,147.0)			  
)
aquacolors = Dict("C" => RGB(0.5,0.5,0.5),
                  "N" => RGB(0.472,0.211,0.499),
                  "H" => RGB(0.65,0.96,0.70),
                  "O" => RGB(0.111,0.37,0.999),
                  "S" => RGB(0.992,0.753,0.525),
				  "ZN" => RGB(0.5,0.5,0.5),
				  "CL" => RGB(0.5,0.5,0.5),
                  "X" => RGB(0.5,0.5,0.5)
)
shapelycolors = OrderedDict(
    "A" => RGB(200.0,200.0,200.0),
    "R" => RGB(20.0,90.0,255.0),
    "N" => RGB(0.0,220.0,220.0),
    "D" => RGB(230.0,10.0,10.0),
    "C" => RGB(230.0,230.0,0.0),
    "Q" => RGB(0.0,220.0,220.0),
    "E" => RGB(230.0,10.0,10.0),
    "G" => RGB(235.0,235.0,235.0),
    "H" => RGB(130.0,130.0,210.0),
    "I" => RGB(15.0,130.0,15.0),
    "L" => RGB(15.0,130.0,15.0),
    "K" => RGB(20.0,90.0,255.0),
    "M" => RGB(230.0,230.0,0.0),
    "F" => RGB(50.0,50.0,170.0),
    "P" => RGB(220.0,150.0,130.0),
    "S" => RGB(250.0,150.0,0.0),
    "T" => RGB(250.0,150.0,0.0),
    "W" => RGB(180.0,90.0,180.0),
    "Y" => RGB(50.0,50.0,170.0),
    "V" => RGB(15.0,130.0,15.0),
    "B" => :gray,
    "Z" => :gray,
    "X" => :gray
)
leskcolors = OrderedDict(
    "A" => :orange,
    "R" => :blue,
    "N" => :magenta,
    "D" => :red,
    "C" => :green,
    "Q" => :magenta,
    "E" => :red,
    "G" => :orange,
    "H" => :magenta,
    "I" => :green,
    "L" => :green,
    "K" => :blue,
    "M" => :green,
    "F" => :green,
    "P" => :green,
    "S" => :orange,
    "T" => :orange,
    "W" => :green,
    "Y" => :green,
    "V" => :green,
    "B" => :gray,
    "Z" => :gray,
    "X" => :gray
)
maecolors = OrderedDict(
    "A" => :lightgreen,
    "R" => :orange,
    "N" => :darkgreen,
    "D" => :darkgreen,
    "C" => :green,
    "Q" => :darkgreen,
    "E" => :darkgreen,
    "G" => :lightgreen,
    "H" => :darkblue,
    "I" => :blue,
    "L" => :blue,
    "K" => :orange,
    "M" => :blue,
    "F" => :purple,
    "P" => :pink,
    "S" => :red,
    "T" => :red,
    "W" => :purple,
    "Y" => :purple,
    "V" => :blue,
    "B" => :gray,
    "Z" => :gray,
    "X" => :gray
)
cinemacolors = OrderedDict(
    "A" => :white,
    "R" => :blue,
    "N" => :green,
    "D" => :red,
    "C" => :yellow,
    "Q" => :green,
    "E" => :red,
    "G" => :brown,
    "H" => :blue,
    "I" => :white,
    "L" => :white,
    "K" => :blue,
    "M" => :white,
    "F" => :magenta,
    "P" => :brown,
    "S" => :green,
    "T" => :green,
    "W" => :magenta,
    "Y" => :magenta,
    "V" => :white,
    "B" => :gray,
    "Z" => :gray,
    "X" => :gray
)
function getbiocolors()
    return [elecolors, cpkcolors, aquacolors, shapelycolors, leskcolors, maecolors, cinemacolors]
end
SMILESaa = OrderedDict(
    "A" => "N[C@@]([H])(C)C(=O)O",
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
    "V" => "N[C@@]([H])(C(C)C)C(=O)O"
)
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
        totalarea += measure(Ngon(Meshes.Point3.(coordinates[connectivity[i,1],:],
						coordinates[connectivity[i,2],:], coordinates[connectivity[i,3],:])))
    end
    return totalarea
end
function linesegs(arr::AbstractArray{T,3}) where T<:AbstractFloat
    new_arr::AbstractArray{Point3f0} = []
    for i in 1:size(arr,1)
        push!(new_arr, Makie.Point3f0(arr[i,1,:]))
        push!(new_arr, Makie.Point3f0(arr[i,2,:]))
    end
    return new_arr |> combinedims |> transpose |> collect
end
# Standard protein residue letter representations.
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
resletterdict = OrderedDict(
	"ALA" => "A",
	"ARG" => "R",
	"ASN" => "N",
	"ASP" => "D",
	"ASX" => "B",
	"CYS" => "C",
	"GLN" => "Q",
	"GLU" => "E",
	"GLX" => "Z",
	"GLY" => "G",
	"HIS" => "H",
	"ILE" => "I",
	"LEU" => "L",
	"LYS" => "K",
	"MET" => "M",
	"PHE" => "F",
	"PRO" => "P",
	"SER" => "S",
	"THR" => "T",
	"TRP" => "W",
	"TYR" => "Y",
	"VAL" => "V",
	"XAA" => "X",
	"XLE" => "J",
	"*" => "*",
	"-" => "-",
	"." => ".",
	"A" => "ALA",
	"R" => "ARG",
	"N" => "ASN",
	"D" => "ASP",
	"B" => "ASX",
	"C" => "CYS",
	"Q" => "GLN",
	"E" => "GLU",
	"Z" => "GLX",
	"G" => "GLY",
	"H" => "HIS",
	"I" => "ILE",
	"L" => "LEU",
	"K" => "LYS",
	"M" => "MET",
	"F" => "PHE",
	"P" => "PRO",
	"S" => "SER",
	"T" => "THR",
	"W" => "TRP",
	"Y" => "TYR",
	"V" => "VAL",
	"X" => "XAA",
	"J" => "XLE"
)
# Dictionary for Kidera physical property factors, from:
# Kenta Nakai, Akinori Kidera, Minoru Kanehisa, Cluster analysis of amino acid indices for prediction of protein structure and function, 
# Protein Engineering, Design and Selection, Volume 2, Issue 2, July 1988, Pages 93–100, https://doi.org/10.1093/protein/2.2.93 
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
    "?" => [0,0,0,0,0,0,0,0,0,0],
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
    "XLE" => [-0.885,-0.08,0.775,-0.935,-0.545,-1.01,0.065,-0.125,0.555,-0.425] 
)
function kdict(str::AbstractString)
    if length(str) == 3
        kideradict3["$(str |> string)"]
    elseif length(str) == 1
        kideradict["$(str |> string)"]
    elseif length(str) > 3
        return [kideradict[(string(str[i]))] for i in 1:length(str)]
    else
        throw(ErrorException("can't get kdict for $str"))
    end
end
kdict(c::Char) = kdict(string(c))
function readdata(filename; titles = true)
    filedata = []

    if endswith(filename,".csv")
        filedata = readdlm(filename,',')
        if titles == true
            filedata = identity.(DataFrame(filedata[2:end,:],filedata[1,:]))
        else
            filedata = identity.(DataFrame(filedata[1:end,:]))
        end
    elseif endswith(filename,".tab")
        filedata = readdlm(filename,'\t')
        if titles == true
            filedata = identity.(DataFrame(filedata[2:end,:],filedata[1,:]))
        else
            filedata = identity.(DataFrame(filedata[1:end,:]))
        end
    elseif endswith(filename,".tsv")
        filedata = readdlm(filename,'\t')
        if titles == true
            filedata = identity.(DataFrame(filedata[2:end,:],filedata[1,:]))
        else
            filedata = identity.(DataFrame(filedata[1:end,:]))
        end
    elseif endswith(filename,".txt")
        filedata = read(filename,String)
        if titles == true
            filedata = identity.(DataFrame(filedata[2:end,:],filedata[1,:]))
        else
            filedata = identity.(DataFrame(filedata[1:end,:]))
        end
    else
        println("filetype not supported")
    end
    
    return filedata
end
