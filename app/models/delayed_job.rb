class DelayedJob < ApplicationRecord
  MAILER = 'mailer'
  PROCESS = 'process'

  scope :ordered, -> { order(id: :desc) }
  belongs_to :client, optional: true

  delegate :cust_name, to: :client, allow_nil: true

  def record_error(error)
    self.last_error = error
    self.attempts += 1
  end

  def run_me
    obj = YAML.load(self.handler)
    obj.perform
    true
  rescue Exception => error
    self.record_error(error.to_s + "\n" + error.backtrace.join("\n"))
    false
  end

end
