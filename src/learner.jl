using LIBLINEAR

const learner_data = Dict{Int, Tuple{Vector{Int}, Vector{Float64}}}()

function learner_append_data(cix, ys, xs)
    global learner_data
    if !haskey(learner_data, cix)
        learner_data[cix] = (Int[], Float64[])
    end
    append!(learner_data[cix][1], ys)
    append!(learner_data[cix][2], xs)
end

function train_models(dim)
    for (k, v) in learner_data
        ys, xs_unshaped = v
        xs = reshape(xs_unshaped, dim, div(length(xs_unshaped), dim))
        model = linear_train(ys, xs)
        yhats, dvs = linear_predict(model, xs)
        @printf("Cluster %d accuracy = %.2f\n", k, mean(yhats.==ys)*100)
    end
end
