# define constants here -
const path_to_package = dirname(pathof(@__MODULE__))

# global packages -
using DifferentialEquations
using DiffEqFinancial
using Statistics
using Distributions
using Dates
using DataFrames
using Reexport
@reexport using PookTradeBase

# include my code ...
include("./base/Types.jl")
include("./base/Compute.jl")
include("./base/Utility.jl")
