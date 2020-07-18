function loadframes(protname::String, frames::AbstractArray{Int64}, modes::Int64; extrapolation = "harmonic")
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{Int64}; extrapolation = "harmonic")
    modes = "$(map(x -> "$(x)", modes)...)"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{UnitRange{Int64}}; extrapolation = "harmonic")
    modes = splatrange(modes)
    modes = "$(first(modes))_1_$(last(modes))"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{StepRange{Int64,Int64}}; extrapolation = "harmonic")
    modes2 = splatrange(modes)
    step = Base.step(modes[])
    modes = "$(first(modes2))_$(step)_$(last(modes2))"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::Int64) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::Int64) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{UnitRange{Int64}}) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}}) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{UnitRange{Int64}}) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}}) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{UnitRange{Int64}};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{UnitRange{Int64}};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}};
            extrapolation = "linear") = loadframes(protname, splatrange(frames); extrapolation = "linear")

# with phases #

function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{Int64}, phases::Int64; extrapolation = "harmonic")
    modes = "$(map(x -> "$(x)", modes)...)"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(phases)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(phases)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{Int64}, phases::AbstractArray{Int64}; extrapolation = "harmonic")
    modes = "$(map(x -> "$(x)", modes)...)"
    phases2 = "$(map(x -> "$(x)", phases)...)"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(phases2)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(phases2)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{UnitRange{Int64}}, phases::Int64; extrapolation = "harmonic")
    modes = splatrange(modes)
    modes = "$(first(modes))_1_$(last(modes))"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(phases)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(phases)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{UnitRange{Int64}}, phases::AbstractArray{Int64}; extrapolation = "harmonic")
    modes = splatrange(modes)
    modes = "$(first(modes))_1_$(last(modes))"
    phases2 = "$(map(x -> "$(x)", phases)...)"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(phases2)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(phases2)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{StepRange{Int64,Int64}}, phases::Int64; extrapolation = "harmonic")
    modes2 = splatrange(modes)
    step = Base.step(modes[])
    modes = "$(first(modes2))_$(step)_$(last(modes2))"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(phases)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(phases)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
function loadframes(protname::String, frames::AbstractArray{Int64}, modes::AbstractArray{StepRange{Int64,Int64}}, phases::AbstractArray{Int64}; extrapolation = "harmonic")
    modes2 = splatrange(modes)
    step = Base.step(modes[])
    modes = "$(first(modes2))_$(step)_$(last(modes2))"
    phases2 = "$(map(x -> "$(x)", phases)...)"
    if extrapolation == "linear"
        filenames = map(x -> "mode_$(modes)_$(phases2)_$(protname)_frame_$(x)", frames)
    else
        filenames = map(x -> "mode_$(modes)_$(phases2)_$(protname)_har_frame_$(x)", frames)
    end
    println("$([filenames...])")
    for i = 1:length(filenames)
        varcall("prot$i", readpdb(filenames[i]))
    end
    loadedprots = [Symbol("prot$i") for i = 1:length(filenames)]
    return loadedprots
end
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::Int64,
            phases::Int64) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::Int64,
            phases::Int64) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::Int64) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::Int64) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::Int64) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::Int64) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::Int64,
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::Int64,
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{Int64},
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{Int64},
            phases::AbstractArray{Int64}) = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "harmonic")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::Int64,
            phases::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::Int64,
            phases::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::Int64;
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::Int64,
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::Int64,
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{UnitRange{Int64}},
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{StepRange{Int64,Int64}},
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{UnitRange{Int64}},
            modes::AbstractArray{Int64},
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::AbstractArray{StepRange{Int64,Int64}},
            modes::AbstractArray{Int64},
            phases::AbstractArray{Int64};
            extrapolation = "linear") = loadframes(protname, splatrange(frames), modes, phases; extrapolation = "linear")
loadframes(protname::String,
            frames::Array{StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},1},
            modes::Base.TwicePrecision{Float64}) = loadframes(protname, splatrange(collect(frames)), float(modes); extrapolation = "linear")
loadframes(protname::String,
            frames::Array{StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},1},
            modes::Array{Float64,1}) = loadframes(protname, splatrange(frames), modes)
loadframes(protname::String,
            frames::Array{Int64,2},
            modes::Array{Float64,1}) = loadframes(protname, splatrange(frames), Int.(modes))
loadframes(protname::String,
            frames::Array{StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},1},
            modes::Base.TwicePrecision{Float64};
            extrapolation::String) = loadframes(protname, splatrange(collect(frames)), float(modes); extrapolation = extrapolation)
loadframes(protname::String,
            frames::Array{StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},1},
            modes::Array{Float64,1};
            extrapolation::String) = loadframes(protname, splatrange(frames), modes; extrapolation = extrapolation)
loadframes(protname::String,
            frames::Array{Int64,2},
            modes::Array{Float64,1};
            extrapolation::String) = loadframes(protname, splatrange(frames), Int.(modes); extrapolation = extrapolation)
