struct Hinge <: AbstractHinge
    parent
    positions::Union{AbstractRange, AbstractArray{Int}, Dict}
    sequence
end
function loadhinges(pdbid::String; hingevars = false)
    dirdat = readdir(hingedir())
    numfiles = 0
    pdbhinges = []
    hinges = Dict{String,Vector{Hinge}}()
    for i = 1:size(dirdat,1)
        if occursin("$pdbid", dirdat[i])
            push!(pdbhinges,load("$(hingedir())\\$(dirdat[i])", "hinges"))
            numfiles+=1
        elseif numfiles > 0
            break
        end
    end
    if hingevars == true
        for j = 1:size(pdbhinges,1)
            varcall("_$(pdbhinges[j][1].parent)_hinges",Vector{Hinge}(pdbhinges[j]))
        end
    else
        for j = 1:size(pdbhinges,1)
            push!(hinges,"$(pdbhinges[j][1].parent)" => pdbhinges[j])
        end
    end
    println("$numfiles hinges loaded for $(pdbid)")
    return hinges
end
