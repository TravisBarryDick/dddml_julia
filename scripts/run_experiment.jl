using DDDML
using ArgParse

function main()
    aps = ArgParseSettings()
    @add_arg_table aps begin
        "--base_directory", "-b"
            help = "Path to parent of train and test directories"
            required = true
        "--clusters", "-k"
            help = "Number of clusters"
            arg_type = Int
            required = true
        "--num_learners", "-l"
            help = "Number of learners"
            arg_type = Int
            required = true
        "--num_dispatchers", "-s"
            help = "Number of dispatchers (-1 for auto)"
            arg_type = Int
            default = -1
        "--dimension", "-d"
            help = "Dimensionality of data"
            arg_type = Int
            required = true
        "--train_size", "-n"
            help = "Number of training examples"
            arg_type = Int
            required = true
        "--dispatch_size", "-m"
            help = "Number of samples to use for dispatch and clustering"
            arg_type = Int
            required = true
    end

    parsed_args = parse_args(ARGS, aps)

    base_directory = parsed_args["base_directory"]
    k = parsed_args["clusters"]
    nl = parsed_args["num_learners"]
    nd = parsed_args["num_dispatchers"]
    if nd == -1
        nd = nprocs() - 1 - nl
    end
    dim = parsed_args["dimension"]
    num_examples = parsed_args["train_size"]
    subsample_size = parsed_args["dispatch_size"]

    wa = WorkerAssignment(nl, nd)
    println(wa)

    train_dir = joinpath(base_directory, "train")
    test_dir = joinpath(base_directory, "test")

    params = Parameters(train_dir, test_dir, dim, num_examples, subsample_size, k)
    println(params)

    # Initialize the dispatchers
    dispatch_init_time = @elapsed init_dispatchers(wa, params)

    # Dispatch the training data in batches
    cluster_dispatch(wa, params)

    # Train the models
    train_time = @elapsed train_models(wa, params)

    # Test the models
    correct, total, test_time = cluster_testing(wa, params)
end

main()
