subsample(wa::WorkerAssignment, params::Parameters) = subsample(wa, params.train_directory, params.train_size, params.subsample_size, params.dim)

function subsample(wa, source_dir, total_lines, desired_lines, dim)
    ys = Array(Int, 0)
    xs = Array(Float64, 0)
    files = files_in_dir(source_dir)
    line_prob = desired_lines / total_lines
    function do_job(w, i)
        fy, fx = remotecall_fetch(w, subsample_worker, files[i], line_prob, dim)
        append!(ys, fy)
        append!(xs, fx)
    end
    schedule_jobs(workers(wa), length(files), do_job)
    ys, reshape(xs, dim, div(length(xs),dim))
end

function subsample_worker(file, p, dim)
    ys = Array(Int, 0)
    xs = Array(Float64, 0)
    fh = open(file, "r")
    for line in eachline(fh)
        if rand() < p
            y, x = libsvm_parse_line(line, dim)
            push!(ys, y)
            append!(xs, x)
        end
    end
    close(fh)
    ys, xs
end
