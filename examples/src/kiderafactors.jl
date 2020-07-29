rezdict = jldopen("examples/data/rezdict.jld2","r") do file
    file["rezdict"]
end
kiderafactors3 = vcat(vcat(vcat(readdlm("examples/data/kiderafactors.csv", ','),[".",[nothing for i = 1:10]...]|>_t),["-",[nothing for i = 1:10]...]|>_t),
    ["*",[nothing for i = 1:10]...]|>_t)
kiderafactors = vcat(vcat(hcat(map(x->rezdict[x], kiderafactors3[:,1]), kiderafactors3[:,2:11])))
kideradict3 = OrderedDict{String,Array{Union{Float64,Nothing},1}}([(kiderafactors3[i,1] => kiderafactors3[i,2:11]) for i = 1:size(kiderafactors3,1)])
kideradict = OrderedDict{String,Array{Union{Float64,Nothing},1}}([(kiderafactors[i,1] => kiderafactors[i,2:11]) for i = 1:size(kiderafactors,1)])
function kdict(str::String)
    if length(str) == 3
        kideradict3["$str"]
    elseif length(str) == 1
        kideradict["$str"]
    else
        throw(ErrorException("can't do dict for $str"))
    end
end
kdict(c::Char) = kdict(string(c))
# JLD2.@load("propresdict.jld2", propresdict)
# function propdict(str::String)
#     if length(str) == 1
#         return propresdict[str]
#     elseif length(str) == 3
#         newstr = resletterdict[str]
#         return propresdict[newstr]
#     else
#         throw(ErrorException("can't do dict for $str"))
#     end
# end
# propdict(c::Char) = propdict(string(c))
