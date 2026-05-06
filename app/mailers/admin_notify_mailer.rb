class AdminNotifyMailer < ActionMailer::Base
  REPLY_TO = ENV['MAIL_USERNAME'] || "thoroughbred.dashboard@gmail.com"
  default from: REPLY_TO

  def notify(user_id, error_text, client_id)
    @user = User.using('pg').find(user_id)
    @error_text = error_text
    @client_id = client_id
    mail(to: @user.email, subject: t('admin.jobs.notify_email_subject'))
  end

end