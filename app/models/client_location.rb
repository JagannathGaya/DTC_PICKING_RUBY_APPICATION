class ClientLocation < ApplicationRecord

  belongs_to :client

  validates :sls_location, presence: true, length: {maximum: 5}
  validates :name, presence: true, length: {maximum: 255}

  scope :ordered, -> { order(:sls_location) }
  scope :for_client, -> (client_id) { where(client_id: client_id)}

  before_save :set_defaults

  private

  def set_defaults
    self.sls_location.upcase! unless self.sls_location.blank?
  end

end
