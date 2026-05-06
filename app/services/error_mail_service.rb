class ErrorMailService

  def initialize(error, from)
    @error = error
    @from = from
  end

  def report
    User.using('pg').where(user_type: 'admin').each do |user|
      text = "ERROR: #{@error.inspect}"
      @from.each do |from|
        text << '\n' + from
      end

      AdminNotifyMailer.delay(queue: DelayedJob::MAILER).notify(user.id, text, nil)
    end
  end

end