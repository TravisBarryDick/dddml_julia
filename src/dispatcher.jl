using LIBLINEAR

function random_dispatch(source_dir, k, num_learners, dim)
    files = files_in_dir(source_dir)
    np = nprocs()
    n = length(files)
    i = 1
    dispatched = 0
    incdispatched(count) = dispatched += count
    nextidx() = (idx = i; i += 1; idx)
    duration = @elapsed @sync begin
        for p in (num_learners+2):np
            @async begin
                while true
                    idx = nextidx()
                    if idx > n
                        break
                    end
                    c = remotecall_fetch(p, random_dispatch_worker,
                                        files[idx], k, num_learners, dim)
                    incdispatched(c)
                end
            end
        end
    end
    @printf("Dispatched examples %d in %.2f sec (%.2f examples / sec)\n",
            dispatched, duration, dispatched / duration)
    for p in 2:num_learners+1
        remotecall_wait(p, list_data)
    end
    for p in 2:num_learners+1
        remotecall_wait(p, train_models, dim)
    end
end

cluster_to_learner(ix, num_learners) = ((ix - 1) % num_learners) + 2

function random_dispatch_worker(file, k, num_learners, dim)
    cys = [Array(Int, 0) for i in 1:k]
    cxs = [Array(Float64, 0) for i in 1:k]
    fh = open(file, "r")
    count = 0
    for line in eachline(fh)
        count += 1
        y, x = libsvm_parse_line(line, dim)
        cix = rand(1:k)
        push!(cys[cix], y)
        append!(cxs[cix], x)
    end
    close(fh)
    for cix in 1:k
        learner_ix = cluster_to_learner(cix, num_learners)
        if length(cys[cix]) > 0
            remotecall(learner_ix, learner_append_data, cix, cys[cix], cxs[cix])
        end
    end
    return count
end

const learner_data = Dict{Int, Tuple{Vector{Int}, Vector{Float64}}}()
const models = Dict{Int, Model}

function learner_append_data(cix, ys, xs)
    global learner_data
    if !haskey(learner_data, cix)
        learner_data[cix] = (Int[], Float64[])
    end
    append!(learner_data[cix][1], ys)
    append!(learner_data[cix][2], xs)
end

function list_data()
    for (k,v) in learner_data
        println("$k : $(length(v[1])) examples.")
    end
end

function train_models(dim)
    for (k, v) in learner_data
        ys, xs_unshaped = v
        xs = reshape(xs_unshaped, dim, div(length(xs_unshaped), div))
        models[k] = linear_train(ys, xs, verbose=true)
    end
end
