function subsample(source_dir, total_lines, desired_lines)
    p = desired_lines / total_lines
    lines = @parallel vcat for file in files_in_dir(source_dir)
        subsample_worker(file, p)::Vector{ASCIIString}
    end
    lines
end

function subsample_worker(file, p)
    lines = Array(ASCIIString, 0)
    fh = open(file, "r")
    for line in eachline(fh)
        if rand() < p
            push!(lines, line)
        end
    end
    lines
end

function subsample_parsed(source_dir, total_lines, desired_lines, dim)
    p = desired_lines / total_lines

    ysxs = @parallel vcat for file in files_in_dir(source_dir)
        subsample_parsed_worker(file, p, dim)
    end
    ys = vcat([ys for (ys,xs) in ysxs]...)
    xs = hcat([xs for (ys,xs) in ysxs]...)
    return ys, xs
end

function subsample_parsed_worker(file, p, dim)
    ys = Array(Int, 0)
    xs = Array(Vector{Float64}, 0)
    fh = open(file, "r")
    for line in eachline(fh)
        if rand() < p
            y, x = libsvm_parse_line(line, dim)
            push!(ys, y)
            push!(xs, x)
        end
    end
    xs_mat = reshape(hcat(xs...), dim, length(xs))
    ys, xs_mat
end
