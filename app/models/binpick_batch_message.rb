class BinpickBatchMessage < TbpView

  self.table_name = 'tbpick_batch_messages_vw'
  self.primary_key = 'seq_no'

  scope :for_batch, -> (batch_id) {where(binpick_batch_id: batch_id)}
  scope :ordered, -> { order(:seq_no)}

end


# BINPICK_BATCH_ID                                   NUMBER
# SEQ_NO                                             NUMBER
# SEVERITY                                           CHAR(1)
# BATCH_STATUS                                       CHAR(1)
# MESSAGE_TEXT                                       CHAR(63)
