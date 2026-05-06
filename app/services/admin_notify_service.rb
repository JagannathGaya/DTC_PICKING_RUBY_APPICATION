class AdminNotifyService

  def initialize
  end


  def notify(res, client)
    User.using('pg').where(user_type: 'admin').each do |user|
      if res.respond_to?('body')
        AdminNotifyMailer.delay(queue: DelayedJob::MAILER, client_id: client.id)
            .notify(user, res.code + ' ' + res.message + ' ' + res.body, client)
      else
        AdminNotifyMailer.delay(queue: DelayedJob::MAILER, client_id: client.id)
            .notify(user, res, client)
      end
    end
  end

  private


end