class AdminTestMailer < ActionMailer::Base
  REPLY_TO = ENV['MAIL_USERNAME'] || "thoroughbred.dashboard@gmail.com"
  default from: REPLY_TO

  def test_email(userid)
    # puts "*************ID****** #{userid.inspect}"
    @user = User.using('pg').find(userid)
    # puts "******************* #{@user.inspect}"
    mail(to: @user.email, subject: t('admin.jobs.test_email_subject'))
  end

end