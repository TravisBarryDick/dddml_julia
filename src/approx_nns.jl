using FLANN

build_nns(X) = flann(X, FLANNParameters())

find_nn(t, x) = nearest(t, x)
