using DDDML

function main()
    base_directory = ARGS[1] # should contain train and test directories
    k = parse(Int, ARGS[2]) # the number of clusters to use
    nl = parse(Int, ARGS[3]) # the number of learners to use
    dim = parse(Int, ARGS[4]) # the dimension of the data
    num_examples = parse(Int, ARGS[5]) # number of training examples
    subsample_size = parse(Int, ARGS[6]) # dispatch sample size

    wa = WorkerAssignment(nl)
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
