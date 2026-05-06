class BinpickBatch < ApplicationRecord

  scope :ordered, -> { order(id: :desc) }
  scope :pickable, -> { where("status in ('I','B','O','P','K','W')") }
  scope :scopen, -> { where(status: 'O') }
  scope :admin, -> { where("status in ('I','B','O','P','K', 'W') or updated_at > ?", Date.today - 8.days) }
  scope :for_status, -> (status) { where(status: status) }
  scope :for_purge, -> { where("status = ? and pack_complete_at < ?", 'C', Date.today-7.days)}
  scope :for_location, -> (location) { where(client_location_id: location.id)}

  belongs_to :user
  belongs_to :client
  belongs_to :client_location

  STATUS_VALUES = %W(I B O P K W C X) # Initial, Being Created, Open, in Process, Picked, Waiting for Pack, Complete, Cancelled
  validates :status, inclusion: {in: STATUS_VALUES, allow_blank: false}
  OPEN = 'O'
  STATUS_LIST = [['All', 'A'],
                 ['Initial', 'I'],
                 ['Being Created', 'B'],
                 ['Open', 'O'],
                 ['In Process', 'P'],
                 ['Picked', 'K'],
                 ['Waiting for Pack', 'W'],
                 ['Complete', 'C'],
                 ['Canceled', 'X']]

  BO_OPTION_VALUES = %W(A B N)
  BACKORDERS = 'B'
  NEWORDERS = 'N'
  validates :bo_option, inclusion: {in: BO_OPTION_VALUES, allow_blank: false}

  def self.bo_option_list(client)
    list = [['Backorders only', 'B'],['New Orders only', 'N']]
    list = list.unshift(['All Orders', 'A']) if client.allow_combined
    list
  end

  def user_name
    user.empno + ' ' + user.name
  end

  def user_no
    user.empno
  end

  def client_name
    client.cust_no + ' ' + client.cust_name
  end

  def client_no
    client.cust_no
  end

  def is_deletable?
    !['B','W','X'].include? self.status
  end

  def not_deletable?
    !is_deletable?
  end

  def is_pickable?
    ['I','B','O','P','K','W'].include? self.status
  end

  def is_open?
    self.status == OPEN
  end

  def has_wave_picks?
    BinpickBin.using(self.client.cust_no).for_batch(self.id).wave_pick.count > 0
  end
end