class BinpickBatchPurgeService

  def initialize()
  end

  def age_them_off
    BinpickBatch.using('pg')
                .where("status in ('C','X')")
                .where('updated_at < current_date - 14')
                .delete_all
    schedule_another
    true
  rescue ActiveRecord::ActiveRecordError => e
    ErrorMailService.new(e, caller_locations.first).report
    raise
  end

  def schedule_another
    BinpickBatchPurgeService.new.delay(run_at: Date.tomorrow + 7.hours, queue: DelayedJob::PROCESS).age_them_off
  end

  private

end