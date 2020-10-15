# -- PRIVATE METHODS --------------------------------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------------------------------------------------- #

# -- PUBLIC METHODS ---------------------------------------------------------------------------------------------------- #
function compute_fibonacci_retracement_levels(data::DataFrame; dataColKeySymbol::Symbol=Symbol("adjusted_close"))::PSResult

    # todo: check - does the data frame contain the dataColKeySymbol?

    # initialize -
    fnrl_array = zeros(6,2)
    fn_array = [0.236 0.382 0.5 0.618 0.786 1.0];

    # find the min and the max in the data being passed in -
    min_value = minimum(data[!,dataColKeySymbol])
    max_value = maximim(data[!,dataColKeySymbol])
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