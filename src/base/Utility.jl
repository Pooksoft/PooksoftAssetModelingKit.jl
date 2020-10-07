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

function compute_linear_return_array(dataTable::DataFrame; key::Symbol = Symbol("adjusted_close"))

    # initialize -
    price_array = Float64[]

    # iterate to build the price array -
    (number_of_rows,number_of_cols) = size(dataTable)
    for row_index = 1:number_of_rows
        data_value = dataTable[row_index,key]
        push!(price_array,data_value)
    end

    # return -
    return compute_linear_return_array(price_array)
end

function compute_log_return_array(priceArray::Array{Float64})::PSResult

    # initialize -
    log_return_array = Array{Float64,1}()

    # get the size -
    number_of_time_steps = length(priceArray)
    for time_index = 2:number_of_time_steps
        value = log((priceArray[time_index]/priceArray[time_index - 1]))
        push!(log_return_array, value)
    end

    # return -
    return PSResult(log_return_array)
end

function compute_return_volatility(dataTable::DataFrame; returnCalcFunction::Function=compute_linear_return_array,
    key::Symbol = Symbol("adjusted_close"))::PSResult

    # initialize -
    price_array = Float64[]

    # iterate to build the price array -
    (number_of_rows,number_of_cols) = size(dataTable)
    for row_index = 1:number_of_rows
        data_value = dataTable[row_index,key]
        push!(price_array,data_value)
    end

    # return -
    return returnCalcFunction(price_array)
end

function compute_return_volatility(priceArray::Array{Float64};
    returnCalcFunction::Function=compute_linear_return_array)::PSResult

    # compute the return array -
    result = returnCalcFunction(priceArray)
    if (isa(result.value,Exception) == true)
        return result
    end
    volatlity = std(result.value)

    # return -
    return PSResult(volatlity)
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