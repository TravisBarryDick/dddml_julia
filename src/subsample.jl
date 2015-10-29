function subsample(source_dir, total_lines, desired_lines, dim)
    ys = Array(Int, 0)
    xs_unshaped = Array(Float64, 0)
    files = files_in_dir(source_dir)
    line_prob = desired_lines / total_lines
    np = nprocs()
    n = length(files)
    i = 1
    nextidx() = (idx = i; i += 1; idx)
    @sync begin
        for p in 1:np
            if p != myid() || np == 1
                @async begin
                    while true
                        idx = nextidx()
                        if idx > n
                            break
                        end
                        file_ys, file_xs = remotecall_fetch(p, subsample_worker,
                                                files[idx], line_prob, dim)
                        append!(ys, file_ys)
                        append!(xs_unshaped, file_xs)
                    end
                end
            end
        end
    end
    xs = reshape(xs_unshaped, dim, div(length(xs_unshaped), dim))
    return ys, xs
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
    ys, xs
end
