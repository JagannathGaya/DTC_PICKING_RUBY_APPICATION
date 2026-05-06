class Admin::DelayedJobsController < Admin::HomeController
  before_action :authorize_admin!

  before_action :find_job, only: [:destroy, :run_job]

  def index
    @delayed_jobs = DelayedJob.ordered.decorate
  end

  def destroy
    @delayed_job.destroy
    if @delayed_job.errors.count == 0
      flash[:notice] = t('admin.jobs.deleted')
    else
      flash[:alert] = t('admin.jobs.not_deleted') + ' ' + @delayed_job.errors.full_messages.flatten.join(' ')
    end
    redirect_to admin_delayed_jobs_path
  end

  def run_job
    if DelayedJobService.new(@delayed_job).run_me
      @delayed_job.destroy
    else
      flash[:alert] = t('admin.jobs.failed')
      @delayed_job.save
    end
    redirect_to admin_delayed_jobs_path
  end

  def new
    DelayedJob.where(queue: DelayedJob::PROCESS).delete_all
    BinpickBatchPurgeService.new.schedule_another
    PageRequestsService.new(Date.today).schedule_another
    redirect_to admin_delayed_jobs_path
  end

  def test_email
    AdminTestMailer.delay(queue: DelayedJob::MAILER).test_email(@current_user.id)
    redirect_to admin_delayed_jobs_path, notice: t('admin.jobs.email_sent')
  end

  private

  def find_job
    @delayed_job = DelayedJob.using('pg').find(params[:id])
  end

end