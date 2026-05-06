class DelayedJobService

  def initialize(delayed_job)
    @delayed_job = delayed_job
  end

  def run_me
    @delayed_job.run_me
  end

end