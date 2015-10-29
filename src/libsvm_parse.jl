function libsvm_parse_line(line, dim)
    tokens = split(strip(line), ' ')
    y = parse(Int, tokens[1])
    x = zeros(Float64, dim)
    for xtoken in tokens[2:end]
        ixstr, valstr = split(xtoken, ':')
        ix = parse(Int, ixstr)
        val = parse(Float64, valstr)
        x[ix] = val
    end
    return y, x
end
