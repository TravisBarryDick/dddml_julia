using FLANN

build_nns(X) = flann(X, FLANNParameters(cores=1))
find_nn(t, x) = nearest(t, x)
