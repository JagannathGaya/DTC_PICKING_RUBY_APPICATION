class AddReceiptItemVendorPo < ActiveRecord::Migration[6.0]
  def change
    add_column :receipt_items, :vendor_id, :string
    add_column :receipt_items, :po_no, :string
  end
end
