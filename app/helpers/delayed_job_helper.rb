module DelayedJobHelper

  def job_delete_link(job)
    return unless job
    link_to admin_delayed_job_path(job), method: :delete, data: {confirm: t('admin.jobs.confirm_delete')}, class: 'btn btn-sm btn-primary' do
      icon('trash') + t('admin.jobs.delete')
    end
  end

  def job_execute_link(job)
    return unless job
    link_to run_job_admin_delayed_job_path(job), method: :put, class: 'btn btn-sm btn-primary' do
      icon('play') + t('admin.jobs.run')
    end
  end

  def job_test_email_link
    link_to test_email_admin_delayed_jobs_path, method: :put, class: 'btn btn-sm btn-primary' do
      icon('envelope') + t('admin.jobs.test_email')
    end
  end

  def job_bootstrap_link
    link_to new_admin_delayed_job_path, method: :get, class: 'btn btn-sm btn-primary' do
      icon('play') + t('admin.jobs.bootstrap')
    end
  end

end