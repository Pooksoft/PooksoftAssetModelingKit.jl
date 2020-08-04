function compute_linear_return_array(priceArray::Array{Float64,1})::PSResult

    # initialize -
    linear_return_array = Array{Float64,1}()

    # get the size -
    number_of_time_steps = length(priceArray)
    for time_index = 2:number_of_time_steps
        value = (priceArray[time_index]/priceArray[time_index - 1]) - 1
        push!(linear_return_array, value)
    end

    # return -
    return PSResult(linear_return_array)
end

function extract(dataTable::DataFrame, start::Date, stop::Date; 
    timestampKey::Symbol = Symbol("timestamp"))::PSResult

    # find index of start -
    idx_start = findfirst(x->x==start,dataTable[!,timestampKey])
    idx_stop = findfirst(x->x==stop,dataTable[!,timestampKey])

    # are either of these indexes empty?
    if (isempty(idx_start) == true || isempty(idx_stop) == stop)
        return PSResult(ErrorException("Inconsistent date range"))
    end

    # extract the set -
    Z = dataTable[min(idx_start,idx_stop):max(idx_start,idx_stop),:]    

    # return -
    return PSResult(Z)
end