# Todo:
# 1. Implement k-means p replication using Lloyd's iteration
# 2. Implement cluster balancing heuristics

using Clustering

function cluster(X, k)
    r = kmeans(X, k)
    return r.totalcost, r.assignments
end

function cluster_sizes(k, as)
    counts = zeros(Int, k)
    for a in as
        counts[a] += 1
    end
    return counts
end
