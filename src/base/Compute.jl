function evaluate(model::PSGeometricBrownianMotionModelParameters, initial_condition::Float64, tspan::Tuple{Float64,Float64}, timeStep::Float64; 
    number_of_trials::Int64=10000, return_time_step::Float64 = 1.0)::PSResult

    # get parameters from the model -
    μ = model.μ
    σ = model.σ

    # setup functions for the model equations -
    f(S,p,t) = μ*S
    g(S,p,t) = σ*S

    # setup the problem -
    problem = SDEProblem(f,g,initial_condition,tspan)

    # how many time steps do we have?
    T = collect(tspan[1]:return_time_step:tspan[2])
    number_of_times_steps = length(T)

    # initilize -
    X = zeros(number_of_times_steps,number_of_trials)

    # solve the model number_of_trials times, and then return the mean and stdev -
    for trial_index = 1:number_of_trials

        # solve the problem -
        solution = solve(problem,EM(),dt=timeStep,saveat=return_time_step) 
        for step_index=1:number_of_times_steps

            # grab the solution 0
            soln_array = solution.u[step_index]
            X[step_index, trial_index] = soln_array[1]
        end
    end

    # compute the mean, and std -
    μ = mean(X,dims=2)
    σ = std(X,dims=2)

    # create a named tuple to return -
    return_tuple = (T=T,X=X,μ=μ,σ=σ)

    # return -
    return PSResult(return_tuple)
end

function evaluate(model::PSHestonAssetPricingModelParameters, initialCondition::Array{Float64,1}, tspan::Tuple{Float64,Float64}, timeStep::Float64; 
    number_of_trials::Int64=10000, return_time_step::Float64 = 1.0)::PSResult

    # setup the problem -
    problem = HestonProblem(model.μ, model.𝝹, model.ϴ, model.σ, model.𝜌, initialCondition, tspan)

    # solve the problem -
    solution = solve(problem,EM(),dt=timeStep,saveat=return_time_step)

    # how many time steps do we have?
    T = collect(tspan[1]:return_time_step:tspan[2])
    number_of_times_steps = length(T)

    # initilize -
    X = zeros(number_of_times_steps,1)
    for step_index=1:number_of_times_steps

        # grab the solution 0
        soln_array = solution.u[step_index]
        X[step_index] = soln_array[1]
    end

    # compute the mean, and std -
    μ = mean(X,dims=2)
    σ = std(X,dims=2)

    # create a named tuple to return -
    return_tuple = (T=T,X=X,μ=μ,σ=σ)

    # return -
    return PSResult(return_tuple)
end

function evaluate(model::PSSingleIndexModelParameters, factorArray::Array{Float64,1}; 
    number_of_samples::Int64 = 100)

    # TODO: checks ...
    # ...

    # get parameters from model -
    ⍺ = model.⍺
    β = model.β
    𝝐 = model.𝝐
    riskFreeRate = model.riskFreeRate
    pV = [⍺ ; β]
    
    # initialize -
    number_of_steps = length(factorArray)
    X = zeros(number_of_steps,2)
    Y = zeros(number_of_steps, number_of_samples)

    # formulate X -
    for step_index = 1:number_of_steps
        X[step_index,1] = 1.0
        X[step_index,2] = (factorArray[step_index,1] - riskFreeRate)
    end

    # formulate Y -
    for sample_index = 1:number_of_samples
        
        # compute delta -
        d = rand(𝝐, number_of_steps)

        # compute tmp -
        Ytmp = X*pV .+ d

        # cache -
        for step_index = 1:number_of_steps
            Y[step_index,sample_index] = Ytmp[step_index]
        end
    end

    # # compute stats from the samples -
    μ = mean(Y,dims=2)
    σ = std(Y,dims=2)

    # return -
    return (Y,μ,σ)
end

function price(model::PSSingleIndexModelParameters, factorArray::Array{Float64,1}, initialPrice::Float64; 
    number_of_samples::Int64 = 100)

    # compute the returns -
    (R,μ,σ) = evaluate(model, factorArray; number_of_samples=number_of_samples)

    # compute return actual (not excess return) -
    R_actual = R .+ model.riskFreeRate

    # get the size -
    (number_of_rows,number_of_cols) = size(R_actual)

    # initialize -
    price_array = zeros(number_of_rows, number_of_samples)

    # samples -
    for sample_index = 1:number_of_samples
        
        # add the initial value -
        price_array[1,sample_index] = initialPrice
        
        # main loop -
        price_value = initialPrice
        for step_index = 2:number_of_rows
            
            # compute new price -
            theta_value = R_actual[step_index-1, sample_index]
            tmp = price_value*(1+theta_value)

            # grab -
            price_array[step_index, sample_index] = tmp

            # update -
            price_value = tmp
        end
    end

    # return -
    return price_array
end

function price(model::PSRandomWalkModelParameters, initialPrice::Float64, number_of_steps::Int64; number_of_samples::Int64 = 100)

    # initialize -
    computed_price_array = zeros(number_of_steps, number_of_samples)

    # draw samples -
    d_matrix = rand(model.𝝐,number_of_steps,number_of_samples)

    # main loop -
    for sample_index = 1:number_of_samples        
        
        # set the initial price -
        computed_price_array[1,sample_index] = initialPrice
        
        # walk through time -
        for step_index = 2:number_of_steps
            value = computed_price_array[step_index-1,sample_index] + d_matrix[step_index,sample_index]
            computed_price_array[step_index,sample_index] = value
        end
    end

    # return -
    return computed_price_array
end

function estimate_single_index_model(assetReturnArray::Array{Float64,1}, factorArray::Array{Float64,1}; 
    riskFreeRate::Float64 = 0.00169)::PSSingleIndexModelParameters

    # TODO: impl checks here ..

    # create X array -
    number_of_time_steps = length(assetReturnArray)
    X = zeros(number_of_time_steps,2)
    for time_index = 1:number_of_time_steps
        X[time_index,1] = 1.0
        X[time_index,2] = (factorArray[time_index,1] - riskFreeRate)
    end

    # Rename the assetReturn array -
    Y = assetReturnArray .- riskFreeRate

    # compute the parameters theta -
    theta = (inv(transpose(X)*X))*transpose(X)*Y

    # ok, so now that we have the parameters, let's compute the residual distribution -
    # TODO: Pass in the distribution type?
    Ymodel = X*theta
    residual_array = (Y - Ymodel)
    D = fit(Laplace, residual_array)

    # create a model wrapper -
    ⍺ = theta[1]
    β = theta[2]
    model_wrapper = PSSingleIndexModelParameters(⍺,β,riskFreeRate,D)

    # return -
    return model_wrapper
end

function estimate_random_walk_model(assetPriceArray::Array{Float64,1})::PSResult

    # TODO: impl checks here ..

    # initialize -
    price_delta_array = Array{Float64,1}()
    number_of_time_steps = length(assetPriceArray)
    
    # compute the price difference array -
    for time_index = 2:number_of_time_steps
        value = assetPriceArray[time_index] - assetPriceArray[time_index-1]
        push!(price_delta_array, value)
    end

    # fit distribution -
    # TODO: Pass in distributon type?
    D = fit(Laplace, price_delta_array)

    # build wrapper and return -
    return PSResult(PSRandomWalkModelParameters(D))
end