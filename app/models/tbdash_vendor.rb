class TbdashVendor < TbpLov

  EXCLUDE_COLUMNS = []

  self.table_name = 'tbdash_vendor_vw'
  self.primary_key = 'lov_id'

  scope :ordered, -> { order(:vendor_name) }


end

