module DDDML

include("filesplit.jl")
include("subsample.jl")
include("libsvm_parse.jl")
include("filesystem_tools.jl")
include("approx_nns.jl")
include("kmeans.jl")
include("dispatcher.jl")
include("learner.jl")
include("testing.jl")

export filesplit, subsample, cluster, build_nns, find_nn, random_dispatch
export train_models, random_testing, init_dispatchers, dispatch, testing

end
