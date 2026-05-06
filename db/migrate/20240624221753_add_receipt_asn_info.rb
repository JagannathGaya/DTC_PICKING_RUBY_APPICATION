class AddReceiptAsnInfo < ActiveRecord::Migration[6.0]
  def change
    add_column :receipt_items, :shipment_no, :string
    add_column :receipt_items, :shipment_line, :string
    add_column :receipt_items, :shipment_date, :string
    add_column :receipt_items, :qty_shipped, :integer
  end
end
