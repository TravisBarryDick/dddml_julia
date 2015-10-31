# Data Dependent Distributed Machine Learning (DDDML)

A distributed implementation of our data dependent machine learning method. We cluster the data using kmeans++ (without any heuristics to keep the cluster sizes balanced) and we use the FLANN library to find nearest neighbors for dispatch. Each learner trains a one-vs-all classifier using liblinear.

## Example Execution on Bros Cluster

```julia
julia> using DDDML

julia> wa = WorkerAssignment(64)
Worker assignment:
  Total workers: 152
  Learners:      64
  Dispatchers:   88

julia> params = Parameters("cifar10_in4d/train/", "cifar10_in4d/test/", 144, 2500000, 1000
0, 64)
DDDML Parameters:
  training data:  cifar10_in4d/train/
  testing data:   cifar10_in4d/test/
  data dimension: 144
  training_size:  2500000
  subsample size: 10000
  (k, p, l, L) =  (64, 1, 0, 9223372036854775807)

julia> @time init_dispatchers(wa, params)
 14.370670 seconds (4.09 M allocations: 292.887 MB, 0.95% gc time)

julia> cluster_dispatch(wa, params)
Dispatched 2500000 examples in 11.38 seconds (0.0046 ms/example)

julia> @time train_models(wa, params)
 20.315266 seconds (20.03 k allocations: 1.176 MB)

# Test performance
julia> cluster_testing(wa, params)
Accuracy: 7985 / 10000 (0.80)
Time: 10000 queries in 0.50 sec (0.0502 ms/query)

# The performance is much worse when we send a query point to a random learner
julia> random_testing(wa, params)
Accuracy: 5865 / 10000 (0.59)
Time: 10000 queries in 0.12 sec (0.0124 ms/query)
```
