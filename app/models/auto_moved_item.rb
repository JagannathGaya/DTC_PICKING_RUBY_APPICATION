# frozen_string_literal: true

class AutoMovedItem < TbpUvw

  EXCLUDE_COLUMNS = %w[id  source_type  source_id  error_msg ]
  COLNAMES = %w[item_no qty_moved from_stock_area from_bin_loc to_stock_area to_bin_loc processed_flag processed_date empno ]

  N = 'N'

  self.table_name = 'tbpick_auto_moved_uvw'
  self.primary_key = 'id'
  scope :unprocessed, -> { where(processed_flag: N) }
  scope :for_empno, -> (empno) { where(empno: empno) }
  scope :ordered, -> { order(:from_stock_area, :from_bin_loc) }

end