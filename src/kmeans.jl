# Todo:
# 1. Implement k-means p replication using Lloyd's iteration
# 2. Implement cluster balancing heuristics

using Clustering

function cluster(X, k)
    r = kmeans(X, k)
    return r.totalcost, r.assignments
end
