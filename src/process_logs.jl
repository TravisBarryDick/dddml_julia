function parse_first_capture{T}(::Type{T}, regex, str)
    m = match(regex, str)
    if m != nothing
        return Nullable{T}(parse(T, m.captures[1]))
    else
        return Nullable{T}()
    end
end

function parse_log_file(path)
    time_regex = r"(\d+(\.\d+)?) sec"
    accuracy_regex = r"\((\d+(\.\d+)?)\)"
    fh = open(path, "r")
    total_time = 0.0
    accuracy = 0.0
    fh = open(path, "r")
    for line in eachline(fh)
        t = parse_first_capture(Float64, time_regex, line)
        a = parse_first_capture(Float64, accuracy_regex, line)
        if !isnull(t); total_time += get(t); end
        if !isnull(a); accuracy = get(a); end
    end
    close(fh)
    return total_time, accuracy
end

function parse_log_directory(path)
    times = Array(Float64, 0)
    accuracies = Array(Float64, 0)
    for f in readdir(path)
        file_path = joinpath(path, f)
        if isfile(file_path)
            t, a = parse_log_file(file_path)
            push!(times, t)
            push!(accuracies, a)
        end
    end
    return times, accuracies
end

function parse_results_directory(path, ks)
    times = Array(Vector{Float64}, 0)
    accuracies = Array(Vector{Float64}, 0)
    for k in ks
        log_directory = joinpath(path, string(k))
        t, a = parse_log_directory(log_directory)
        push!(times, t)
        push!(accuracies, a)
    end
    return ks, times, accuracies
end
