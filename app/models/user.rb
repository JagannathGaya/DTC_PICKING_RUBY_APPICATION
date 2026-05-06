class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable, :async

  LOCALES = [ %w(English en), [ 'Espa&ntilde;ol'.to_s.html_safe, 'es']]
  USER_TYPES = { admin: I18n.t('user.type.admin'), user: I18n.t('user.type.user'), host: I18n.t('user.type.host') }
  HOST = 'host'
  CLIENT = 'user'

  scope :ordered, -> { order(:email) }
  scope :client_users, -> { where(user_type: CLIENT) }
  scope :host_users, -> {where(user_type: HOST)}
  scope :permit_users, -> { where(user_type: [CLIENT, HOST]) }

  belongs_to :client, optional: true
  has_many :picks, dependent: :destroy
  has_many :permits, dependent: :destroy
  has_many :waves, dependent: :destroy

  validates :time_zone, inclusion: {in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true}
  validates :name, length: { maximum: 255}, allow_blank: true
  validates :user_type, inclusion: {in: USER_TYPES.keys.map(&:to_s), allow_blank: false}
  validate { |user| UserValidator.new(user).validate}

  before_validation :set_defaults

  def user?
    self.user_type == 'user'
  end

  def admin?
    self.user_type == 'admin'
  end

  def host?
    self.user_type == 'host'
  end

  def generate_api_key
    self.update_column(:api_key, SecureRandom.hex(16))
  end

  def add_permits_from_template()
    from_user = User.using('pg').where(email: Rails.application.config.template_user).first
    from_user.permits.each do |permit|
      self.permits.create!(report_name: permit.report_name,
                           client_id: permit.client_id ? self.client_id : nil,
                           allow: permit.allow)
    end if from_user
  end

  private

  def set_defaults
    self.time_zone = nil if self.time_zone.blank?
    self.locale = nil if self.locale.blank?
    self.name = nil if self.name.blank?
    self.empno = nil if self.empno.blank?
    self.client_id = nil if self.client_id.blank?
  end

end
