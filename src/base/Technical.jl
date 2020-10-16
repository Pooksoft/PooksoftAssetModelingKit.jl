# -- PRIVATE METHODS --------------------------------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------------------------------------------------- #

# -- PUBLIC METHODS ---------------------------------------------------------------------------------------------------- #
function compute_exponential_moving_average(data::DataFrame, startDate::Date, delay::Int64; 
    timestampColKeySymbol::Symbol=Symbol("timestamp"), dataColKeySymbol::Symbol=Symbol("adjusted_close"))::PSResult

    # initialize -
    price_array = Array{Float64,1}()
    exponential_moving_average = Array{Float64,1}()

    # check: delay is non-negative?
    if (delay<0)
        return PSResult(ArgumentError("delay parameter must be non-negative"))
    end

    # find the index of this date -
    idx_start_date = findfirst(x->x==startDate, data[!, timestampColKeySymbol])
    if (idx_start_date === nothing)
        return PSResult(ArgumentError("the start date is not contained in the data set"))
    end

    # populate the price array -
    (number_of_days,number_of_cols) = size(data)
    for index = idx_start_date:number_of_days
        value = data[index,dataColKeySymbol]
        push!(price_array, value)
    end

    # compute the SMA (start point) -
    tmp_array = Array{Float64,1}()
    for index = 1:delay
        value = price_array[index]
        push!(tmp_array,value)
    end
    SMA = mean(tmp_array)

    # what is the weight parameter -
    ω = 2.0/(delay+1.0)

    # compute -
    push!(exponential_moving_average,SMA)
    for index = 1:number_of_days

        price_value = price_array[index]
        EMA_old = exponential_moving_average[index]
        EMA_new = ω*price_value+(1.0 - ω)*EMA_old
        push!(exponential_moving_average, EMA_new)
    end

    # return -
    return PSResult(exponential_moving_average)
end

function compute_fibonacci_retracement_levels(data::DataFrame; 
    dataColKeySymbol::Symbol=Symbol("adjusted_close"))::PSResult

    # todo: check - does the data frame contain the dataColKeySymbol?

    # initialize -
    fnrl_array = zeros(7,2)
    fn_array = [0.0 0.236 0.382 0.5 0.618 0.786 1.0];

    # find the min and the max in the data being passed in -
    min_value = minimum(data[!,dataColKeySymbol])
    max_value = maximum(data[!,dataColKeySymbol])
    𝝙 = max_value - min_value

    # compute the levels -
    for (index,level) in enumerate(fn_array)
        tmp = max_value - 𝝙*level
        fnrl_array[index,1] = level
        fnrl_array[index,2] = tmp
    end

    # return -
    return PSResult{Array{Float64,2}}(fnrl_array)
end
# ---------------------------------------------------------------------------------------------------------------------- #