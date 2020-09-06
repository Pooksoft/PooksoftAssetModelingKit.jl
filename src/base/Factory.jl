function build_geometric_brownian_motion_model(μ::Float64 = 0.0,σ::Float64 = 0.0)::PSResult

    # TODO - checks: ate the parameters passed in legit?
    if (μ < 0.0 || σ < 0.0)
        return PSResult{ArgumentError}(ArgumentError("Postive values are expected for both μ and σ"))
    end

    # build -
    μ_corrected = (μ/100.0)
    type_object = PSGeometricBrownianMotionModelParameters(μ_corrected,σ)

    # return wrapped -
    return PSResult{PSGeometricBrownianMotionModelParameters}(type_object)
end

function build_geometric_brownian_motion_model(dict::Dict{String,Any})::PSResult

    # Check: does the dictionary have the correct key?
    if (haskey(dict,"underlying_model_parameters") == false)
        return PSResult{ArgumentError}(ArgumentError("Dictionary does not contain the underlying_model_parameters key"))
    end

    # get data -
    underlying_dictionary = dict["underlying_model_parameters"]

    # Check: is the data correct in the underlying_dictionary?
    μ = underlying_dictionary["price_growth_rate"]
    σ = underlying_dictionary["price_volatility"]
    if (μ < 0.0 || σ < 0.0)
        return PSResult{ArgumentError}(ArgumentError("Postive values are expected for both μ and σ"))
    end

    # call -> return PSResult wrapper model -
    return build_geometric_brownian_motion_model(μ,σ)
end