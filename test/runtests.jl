using PooksoftAssetModelingKit
using CSV
using DataFrames
using Test
using Statistics

function run_gbm_model_simulation()

    # test setup -
    path_test_data_file = "./data/Test.csv"

    # load the data file -
    data_table = CSV.read(path_test_data_file,DataFrame)

    # estimated the average return
    result = compute_linear_return_array(data_table)
    if (isa(result.value,Exception) == true)
        return false
    end
    μ = mean(result.value)

    # estimate the average volatility -
    result = compute_return_volatility(data_table)
    if (isa(result.value,Exception) == true)
        return false
    end
    σ = result.value

    # build the model object -
    result = build_geometric_brownian_motion_model(μ,σ)
    if (isa(result.value,Exception) == true)
        return false
    end
    model = result.value

    # setup and run the simulation -
    tspan = (0.0,14.0)
    stepSize = 0.0001
    initial_condition = 83.81
    number_of_trials = 100

    # run -
    result = evaluate(model,initial_condition,tspan,stepSize;number_of_trials=number_of_trials)
    if (isa(result.value,Exception) == true)
        return false
    end
    simulation_result = result.value

    # check types on the return -
    if (haskey(simulation_result,:X) == true && haskey(simulation_result,:T) == true)
        return true
    end

    # default is to fail (just like everyhting I do in life ...)
    return false
end


@testset "asset_modeling_test_set" begin
    @test run_gbm_model_simulation() == true
end