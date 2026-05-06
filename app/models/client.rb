class Client < ApplicationRecord
  has_attached_file :logo, :styles => { :thumb => ['125x50>', :png] }, default_url: "tbp_logo.gif"
  # validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/
  do_not_validate_attachment_file_type :logo

  has_many :users, dependent: :destroy
  has_many :permits, dependent: :destroy
  has_many :client_locations, dependent: :destroy
  has_many :binpick_batches, dependent: :destroy

  validates :cust_no, presence: true, length: {maximum: 10}
  validates :cust_name, presence: true, length: {maximum: 255}

  scope :ordered, -> { order(:cust_no) }
  scope :filtered, -> (cust_no) { where('cust_no like ?', cust_no.upcase+'%') unless cust_no.blank? }

  before_save :set_defaults

  private

  def set_defaults
    self.cust_no.upcase! unless self.cust_no.blank?
    self.username.upcase! unless self.username.blank?
  end

end
