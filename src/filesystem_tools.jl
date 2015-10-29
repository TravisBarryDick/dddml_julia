function files_in_dir(dir)
    files = Array(ASCIIString, 0)
    for f in readdir(dir)
        p = joinpath(dir, f)
        if isfile(p)
            push!(files, p)
        end
    end
    files
end
