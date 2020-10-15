module PooksoftAssetModelingKit

# include -
include("Include.jl")

# export methods -
export price
export evaluate
export sample_underlying_gbm_model
export estimate_single_index_model
export estimate_random_walk_model
export compute_linear_return_array
export compute_log_return_array
export compute_return_volatility

# technical indicators methods -
export compute_fibonacci_retracement_levels

# factory methods -
export build_geometric_brownian_motion_model

# export types -
export PSGeometricBrownianMotionModelParameters
export PSHestonAssetPricingModelParameters
export PSSingleIndexModelParameters
export PSRandomWalkModelParameters

end # module
