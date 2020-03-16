import Base.-, Base.+
-(N::Nothing, F::Float64) = 5.0
+(N::Nothing, F::Float64) = 5.0
-(F::Float64, N::Nothing) = 5.0
+(F::Float64, N::Nothing) = 5.0
-(F::Nothing, N::Nothing) = 5.0
+(F::Nothing, N::Nothing) = 5.0

function filterresletters(arr::AbstractArray; letters = rezletters, print = false)
    arr2::Vector{Array{String,1}} = []
    indices::Vector{Int64} = []
    inaas = true
    for i = 1:size(arr,1)
        for j = 1:size(arr[i],1)
            if !(arr[i][j] in letters)
                inaas = false
            end
        end
        if inaas == true
            push!(arr2,arr[i][:])
            push!(indices, i)
        end
        inaas = true
    end
	if print == true
		for i = 1:size(arr,1)
	        for j = 1:size(arr[i],1)
	            if !(arr[i][j] in letters)
	                print("$(arr[i][j]) ")
	            end
	        end
	    end
	end
    return (arr2 |> combinedims |> _t, indices)
end

doublemutants = readdlm("$(datadir())\\pairfreq.double.change_1-40.txt")
