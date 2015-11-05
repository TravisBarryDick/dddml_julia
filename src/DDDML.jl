module DDDML

# Parameters and configuration
include("WorkerAssignment.jl")
include("Parameters.jl")
export WorkerAssignment
export Parameters

# Some utiltiies
include("Scheduler.jl")
include("libsvm_parse.jl")
include("filesystem_tools.jl")

# Splitting training files into job-sized files
include("filesplit.jl")
export filesplit

# Subsampling the data
include("subsample.jl")
export subsample

# Dispatching the data
include("approx_nns.jl")
include("kmeans.jl")
include("dispatcher.jl")
export init_dispatchers, random_dispatch, cluster_dispatch

# Code for the learners
include("learner.jl")
export train_models, predict

# Code to query testing data one-by-one
include("testing.jl")
export random_testing, cluster_testing

# Code for processing the output logs
include("process_logs.jl")
export parse_log_file, parse_log_directory, parse_results_directory

end
