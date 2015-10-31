immutable Parameters
    train_directory::ASCIIString
    test_directory::ASCIIString
    dim::Int
    train_size::Int
    subsample_size::Int
    k::Int
    p::Int
    l::Int
    L::Int
    function Parameters(train_directory, test_directory, dim, train_size,
                        subsample_size, k, p = 1, l = 0, L = typemax(Int))
        new(train_directory, test_directory, dim, train_size, subsample_size,
            k, p, l, L)
    end
end

import Base.show
function show(io::Base.IO, p::Parameters)
    println(io, "DDDML Parameters:")
    println(io, "  training data:  $(p.train_directory)")
    println(io, "  testing data:   $(p.test_directory)")
    println(io, "  data dimension: $(p.dim)")
    println(io, "  training_size:  $(p.train_size)")
    println(io, "  subsample size: $(p.subsample_size)")
    print(io,   "  (k, p, l, L) =  ($(p.k), $(p.p), $(p.l), $(p.L))")
end
