class Permit < ApplicationRecord

  belongs_to :client
  belongs_to :user

  validates :report_name, presence: true, length: {maximum: 255}

  scope :ordered, -> { order(:report_name).order(:client_id).order(:user_id) }
  scope :for_report, -> (report) { where(report_name: report) }
  scope :for_client, -> (client_id) { where(client_id: client_id) }
  scope :for_user, -> (user_id) { where(user_id: user_id) }

end
