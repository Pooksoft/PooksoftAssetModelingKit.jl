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

struct PSSingleIndexModelParameters <: PSAbstractAssetReturnModel

    # model parameters -
    ⍺::Float64
    β::Float64
    riskFreeRate::Float64
    𝝐::ContinuousUnivariateDistribution

    function PSSingleIndexModelParameters(⍺, β, riskFreeRate, 𝝐)
        this = new(⍺, β, riskFreeRate, 𝝐)
    end
end

struct PSRandomWalkModelParameters <: PSAbstractAssetReturnModel

    # model parameters -
    𝝐::ContinuousUnivariateDistribution

    function PSRandomWalkModelParameters(𝝐)
        this = new(𝝐)
    end
end