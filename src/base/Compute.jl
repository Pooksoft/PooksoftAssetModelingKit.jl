function evaluate(model::PSGeometricBrownianMotionModelParameters, initial_condition::Float64, tspan::Tuple{Float64,Float64}, timeStep::Float64; 
    number_of_trials::Int64=10000, return_time_step::Float64 = 1.0)

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

    # return -
    return (T,X,μ,σ)
end

function evaluate(model::PSHestonAssetPricingModelParameters, initialCondition::Array{Float64,1}, tspan::Tuple{Float64,Float64}, timeStep::Float64; 
    number_of_trials::Int64=10000, return_time_step::Float64 = 1.0)

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

    # return -
    return (T,X)
end

function evaluate(model::PSSingleIndexModelParameters; factorArray::Array{Float64,2}; 
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
    (number_of_steps, number_of_cols) = size(factorArray)
    assetReturnArray = zeros(number_of_steps, 3)
    X = zeros(number_of_steps,2)
    Y = zeros(number_of_steps,number_of_samples)

    # formulate X -
    for step_index = 1:number_of_steps
        X[step_index,1] = 1.0
        X[step_index,2] = (factorArray[step_index,2] - riskFreeRate)
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

    # # package -
    for step_index = 1:number_of_steps 
        assetReturnArray[step_index,1] = factorArray[step_index,1]
        assetReturnArray[step_index,2] = μ[step_index]
        assetReturnArray[step_index,3] = σ[step_index]
    end

    return assetReturnArray
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