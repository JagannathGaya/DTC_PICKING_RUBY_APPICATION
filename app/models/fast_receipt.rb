class FastReceipt < TbpUvw

    YES = "Y"

    self.table_name = 'fast_receipt_uvw'
    self.primary_key = 'fast_reference'

    set_datetime_columns :date_expires, trans_date if ActiveRecord::Base.connection.respond_to? :set_datetime_columns

    private

end