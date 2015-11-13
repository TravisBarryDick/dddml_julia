init_dispatchers(wa::WorkerAssignment, params::Parameters) =
    init_dispatchers(wa, params.train_directory, params.train_size,
                     params.subsample_size, params.dim, params.k)

function init_dispatchers(wa, source_dir, total_lines, desired_lines, dim, k)
    tic()
    ys, xs = subsample(wa, source_dir, total_lines, desired_lines, dim)
    cost, as = cluster(xs, k)
    println("Cluster sizes: ", cluster_sizes(k, as))
    @sync for w in dispatchers(wa)
        @async remotecall_wait(w, init_dispatchers_worker, xs, as)
    end
    duration = toq()
    @printf("Dispatchers initialized in %.2f sec\n", duration)
end

function init_dispatchers_worker(xs, as)
    global const dispatcher_data = xs
    global const dispatcher_as = as
    global const dispatcher_nns = build_nns(xs)
end

function dispatch(wa, worker_fn, source_dir, dim, k)
    files = files_in_dir(source_dir)
    dispatched = 0
    function do_job(w, i)
        count = remotecall_fetch(w, worker_fn, wa, files[i], dim, k)
        dispatched += count
    end
    duration = @elapsed schedule_jobs(dispatchers(wa), length(files), do_job)
    @printf("Dispatched %d examples in %.2f seconds (%.4f ms/example)\n",
            dispatched, duration, duration / dispatched * 1000 *
            num_dispatchers(wa))
end

random_dispatch(wa, source_dir, dim, k) =
    dispatch(wa, random_dispatch_worker, source_dir, dim, k)
random_dispatch(wa, params) =
    random_dispatch(wa, params.train_directory, params.dim, params.k)

cluster_dispatch(wa, source_dir, dim, k) =
    dispatch(wa, cluster_dispatch_worker, source_dir, dim, k)
cluster_dispatch(wa, params) =
    cluster_dispatch(wa, params.train_directory, params.dim, params.k)

function dispatch_worker(wa, file, dim, k, rand_dispatch)
    global dispatcher_nns
    global dispatcher_as
    cys = [Array(Int, 0) for i in 1:k]
    cxs = [Array(Float64, 0) for i in 1:k]
    fh = open(file, "r")
    count = 0
    for line in eachline(fh)
        count += 1
        y, x = libsvm_parse_line(line, dim)
        if rand_dispatch
            cix = rand(1:k)
        else
            nn_ix = find_nn(dispatcher_nns, x)[1][1]
            cix = dispatcher_as[nn_ix]
        end
        push!(cys[cix], y)
        append!(cxs[cix], x)
    end
    close(fh)
    for i in 1:k
        if length(cys[i]) == 0; continue; end
        remotecall(get_learner(wa, i), learner_append_data, i, cys[i], cxs[i])
    end
    return count
end

random_dispatch_worker(wa, file, dim, k) = dispatch_worker(wa, file, dim, k, true)

cluster_dispatch_worker(wa, file, dim, k) = dispatch_worker(wa, file, dim, k, false)
