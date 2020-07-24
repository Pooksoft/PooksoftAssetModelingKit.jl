struct PSHestonAssetPricingModelParameters <: PSAbstractAssetReturnModel

    # data -
    μ::Float64
    𝝹::Float64
    ϴ::Float64
    σ::Float64
    𝜌::Float64

    function PSHestonAssetPricingModelParameters(μ::Float64, 𝝹::Float64, ϴ::Float64, σ::Float64, 𝜌::Float64)
        this = new(μ,𝝹,ϴ,σ,𝜌)
    end
end

struct PSGeometricBrownianMotionModelParameters <: PSAbstractAssetReturnModel

    # model parameters -
    μ::Float64
    σ::Float64

    function PSGeometricBrownianMotionModelParameters(μ=0.0,σ=0.0)
        this = new(μ,σ)
    end
end

struct PSSingleIndexModelParameters

    # model parameters -
    ⍺::Float64
    β::Float64
    𝝐::ContinuousUnivariateDistribution
    riskFreeRate::Float64

    function PSSingleIndexModelParameters(⍺=0.0, β=0.0, 𝝐, riskFreeRate=0.0)
        this = new(⍺, β, 𝝐, riskFreeRate)
    end
end