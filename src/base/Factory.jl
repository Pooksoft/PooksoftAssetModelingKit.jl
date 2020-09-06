function build_geometric_brownian_motion_model(μ::Float64 = 0.0,σ::Float64 = 0.0)::PSResult

    # TODO - checks: ate the parameters passed in legit?
    if (μ < 0.0 || σ < 0.0)
        return PSResult{ArgumentError}(ArgumentError("Postive values are expected for both μ and σ"))
    end

    # build -
    type_object = PSGeometricBrownianMotionModelParameters(μ,σ)

    # return wrapped -
    return PSResult{PSGeometricBrownianMotionModelParameters}(type_object)
end