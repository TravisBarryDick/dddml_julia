# Uses the split program to divide a dataset into files, each consisting of at
# most n lines.
function filesplit(source, dest_dir, file_prefix="file_", n = 200)
    if !isdir(dest_dir)
        mkpath(dest_dir)
    end
    prefix = joinpath(dest_dir, file_prefix)
    run(`split -a 6 -l $n $source $prefix`)
end
