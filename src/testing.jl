function random_testing(source_dir, k, num_learners, dim)
    files = files_in_dir(source_dir)
    np = nprocs()
    n = length(files)
    i = 1
    total = 0
    correct = 0
    update_tally(t,c) = (total += t; correct += c)
    nextidx() = (idx = i; i += 1; idx)
    duration = @elapsed @sync begin
        for p in (num_learners+2):np
            @async begin
                while true
                    idx = nextidx()
                    if idx > n
                        break
                    end
                    c, t = remotecall_fetch(p, random_testing_worker,
                                            files[idx], k, num_learners, dim)
                    update_tally(c, t)
                end
            end
        end
    end
    @printf("Accuracy: %d / %d (%.2f)\n", correct, total, correct / total)
    @printf("Time: %d queries in %.2f sec (%.2f queries / sec)\n", total, duration, total / duration)
end

function random_testing_worker(file, k, num_learners, dim)
    fh = open(file, "r")
    total = 0
    correct = 0
    for line in eachline(fh)
        y, x = libsvm_parse_line(line, dim)
        cix = rand(1:k)
        yhat = remotecall_fetch(cluster_to_learner(cix, num_learners), predict, cix, reshape(x, length(x), 1))
        total += 1
        if yhat == y
            correct += 1
        end
    end
    close(fh)
    return total, correct
end
