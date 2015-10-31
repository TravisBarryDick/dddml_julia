immutable WorkerAssignment
    num_workers::Int
    num_learners::Int
end
WorkerAssignment(num_learners) = WorkerAssignment(nprocs() - 1, num_learners)

function wrap(i, n)
    ix = (i - 1) % n + 1
    if ix < 1
        ix += n
    end
    return ix
end

# How many of each kind of worker are there?
num_workers(wa::WorkerAssignment) = wa.num_workers
num_learners(wa::WorkerAssignment) = wa.num_learners
num_dispatchers(wa::WorkerAssignment) = wa.num_workers - wa.num_learners

# Given the index of either a learner or a dispatcher, return the worker index.
# Wraps indices around, so this can actually be used to assign job numbers to
# learners / dispatchers.
get_learner(wa::WorkerAssignment, i) = wrap(i, num_learners(wa)) + 1
get_dispatcher(wa::WorkerAssignment, i) = wa.num_learners + 1 + wrap(i, num_dispatchers(wa))

# Iterators over the workers
workers(wa::WorkerAssignment) = 2:num_workers(wa)
learners(wa::WorkerAssignment) = get_learner(wa, 1):get_learner(wa, num_learners(wa))
dispatchers(wa::WorkerAssignment) = get_dispatcher(wa, 1):get_dispatcher(wa, num_dispatchers(wa))

# Showing the worker assignment
import Base.show
function show(io::Base.IO, wa::WorkerAssignment)
    println(io, "Worker assignment:")
    println(io, "  Total workers: $(num_workers(wa))")
    println(io, "  Learners:      $(num_learners(wa))")
    print(io,   "  Dispatchers:   $(num_dispatchers(wa))")
end
