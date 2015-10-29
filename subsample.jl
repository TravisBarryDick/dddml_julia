function subsample(source_dir, total_lines, desired_lines)
    p = desired_lines / total_lines
    lines = @parallel vcat for file in files_in_dir(source_dir)
        subsample_worker(file, p)
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
