class PageRequestsService

  def initialize(as_of)
    @as_of = as_of
  end

  def age_them_off
    PageRequest.using('pg').where('created_at < current_date - 14').delete_all
    # schedule_another
    true
  rescue ActiveRecord::ActiveRecordError => e
    ErrorMailService.new(e, caller_locations.first).report
    raise
  end

  def schedule_another
    PageRequestsService.new(Date.tomorrow).delay(run_at: Date.tomorrow + 4.hours + 30.minutes, queue: DelayedJob::PROCESS).age_them_off
  end

  private


end