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
end

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

cluster_to_learner(ix, num_learners) = ((ix - 1) % num_learners) + 2
