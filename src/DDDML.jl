module DDDML

include("filesplit.jl")
include("subsample.jl")
include("libsvm_parse.jl")
include("filesystem_tools.jl")
#include("kmeans.jl")
#include("approx_nns.jl")
include("dispatcher.jl")
include("learner.jl")

export filesplit, subsample, cluster, build_nns, find_nn, random_dispatch


end
