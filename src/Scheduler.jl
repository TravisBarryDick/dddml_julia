function schedule_jobs(workers, num_jobs, do_job)
    next_i = 1
    get_next_i() = (i = next_i; next_i += 1; i)
    @sync for w in workers
        @async while true
            i = get_next_i()
            if i > num_jobs; break; end
            do_job(w, i)
        end
    end
end
