using PooksoftAssetModelingKit
using CSV
using DataFrames
using Test
using Statistics
using KernelDensity
using Dates

function estimate_random_walk_model_test()

    # test setup -
    ticker_symbol = 
    path_test_data_file = "./data/Test.csv"

    # load the data file -
    df = CSV.read(path_test_data_file,DataFrame)

    # what dates are we going to look at?
	date_start = Date("2016-01-04")
    date_stop = Date("2020-10-09")
    
    # filter the date range we want -
	tmp = filter(r->(r.timestamp >= date_start && r.timestamp <= date_stop),df)

    # compute the difference for each ticker -
	result = compute_linear_return_array(tmp)
	if (isa(result.value, Exception) == true)
		return false
	end
    price_return_array = result.value
    
    # grab the model - is this the right type?
	model = kde_lscv(price_return_array)
    if (isa(model, UnivariateKDE) == false)
        return false
    end

    # we got here - all is ok
    return true
end

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
    @test estimate_random_walk_model_test() == true
end