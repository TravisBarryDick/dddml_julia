using LIBLINEAR

const learner_data = Dict{Int, Tuple{Vector{Int}, Vector{Float64}}}()
const learner_models = Dict{Int, LIBLINEAR.LINEARModel{Int}}()

function learner_append_data(cix, ys, xs)
    global learner_data
    if !haskey(learner_data, cix)
        learner_data[cix] = (Int[], Float64[])
    end
    append!(learner_data[cix][1], ys)
    append!(learner_data[cix][2], xs)
end

function train_models(num_learners, dim)
    global learner_data
    global learner_models
    @sync begin
        for p in 2:num_learners+1
            @async begin
                remotecall_wait(p, train_models_worker, dim)
            end
        end
    end
end

function train_models_worker(dim)
    global learner_data
    global learner_models
    for (k, v) in learner_data
        ys, xs_unshaped = v
        xs = reshape(xs_unshaped, dim, div(length(xs_unshaped), dim))
        learner_models[k] = linear_train(ys, xs)
    end
end

function predict(cix, xs)
    global learner_data
    global learner_models
    if !haskey(learner_models, cix)
        error("This learner does not have a model for cluster $cix")
    end
    yhat = linear_predict(learner_models[cix], xs)[1][1]
    return yhat
end
