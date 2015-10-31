function testing(wa, worker_fn, source_dir, dim, k)
    files = files_in_dir(source_dir)
    correct = 0
    total = 0
    function do_job(w, i)
        c, t = remotecall_fetch(w, worker_fn, wa, files[i], dim, k)
        correct += c
        total += t
    end
    duration = @elapsed schedule_jobs(dispatchers(wa), length(files), do_job)
    @printf("Accuracy: %d / %d (%.2f)\n", correct, total, correct / total)
    @printf("Time: %d queries in %.2f sec (%.4f ms/query)\n",
            total, duration, duration / total * 1000)
end

random_testing(wa, source_dir, dim, k) =
    testing(wa, random_testing_worker, source_dir, dim, k)
random_testing(wa, params) =
    random_testing(wa, params.test_directory, params.dim, params.k)

cluster_testing(wa, source_dir, dim, k) =
    testing(wa, cluster_testing_worker, source_dir, dim, k)
cluster_testing(wa, params) =
    cluster_testing(wa, params.test_directory, params.dim, params.k)

function testing_worker(wa, file, dim, k, rand_dispatch)
    fh = open(file, "r")
    total = 0
    correct = 0
    for line in eachline(fh)
        y, x = libsvm_parse_line(line, dim)
        if rand_dispatch
            cix = rand(1:k)
        else
            nn_ix = find_nn(dispatcher_nns, x)[1][1]
            cix = dispatcher_as[nn_ix]
        end
        yhat = remotecall_fetch(get_learner(wa, cix), predict,
                                cix, reshape(x, length(x), 1))
        total += 1
        if yhat == y
            correct += 1
        end
    end
    close(fh)
    return correct, total
end

random_testing_worker(wa, file, dim, k) =
    testing_worker(wa, file, dim, k, true)

cluster_testing_worker(wa, file, dim, k) =
    testing_worker(wa, file, dim, k, false)
