class Order < TbpView
  self.table_name = 'tbpick_orders_vw'
  self.primary_key = 'order_no'
  set_date_columns :estship_dt if ActiveRecord::Base.connection.respond_to? :set_date_columns
  scope :ordered, -> { order(:order_no) }
  scope :exclude_orders, -> (list) {  list.length != 0 ? where("order_no not in (#{list})") : where("1=1") if list }
  def order_number
    self.order_no.to_s + '-' + self.order_suffix.to_s
  end

end
