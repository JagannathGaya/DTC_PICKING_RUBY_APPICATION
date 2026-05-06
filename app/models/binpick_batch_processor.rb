# frozen_string_literal: true
#
class BinpickBatchProcessor < TbpUvw

  self.table_name = 'tbpick_batch_proc_uvw'
  self.primary_key = 'nds_number'  # UVWS being inserted into must be based on single-table select and have primary key constraint column matching this

end

# sls_location                                       varchar2(5)   -- sales location
# binpick_batch_id                                   number
# action                                             char(1)
# start_order_seq                           not null number(5)
# end_order_seq                             not null number(5)