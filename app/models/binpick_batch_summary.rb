class BinpickBatchSummary < TbpView

  self.table_name = 'tbpick_batch_summary_vw'
  self.primary_key = 'seq_no'

  scope :for_batch, -> (batch_id) {where(binpick_batch_id: batch_id)}
  scope :for_location, -> (sls_location) {where(sls_location: sls_location)}
  scope :for_status, -> (status) {where(batch_status: status)}
  scope :expected_orders, -> (bo_option) {where("batch_status = ? and ((stat_type = 'Status J New Orders' and ? in ( 'A','N'))  or (stat_type = 'Status J Backorders' and ? in ('A','B')))", 'I', bo_option, bo_option)}
  scope :ordered, -> { order(:seq_no) }

end

# SEQ_NO                                             NUMBER
# BINPICK_BATCH_ID                                   NUMBER
# STAT_TYPE                                          VARCHAR2(17)
# SLS_LOCATION                                       VARCHAR2(5)
# STAT_VALUE                                         NUMBER
# BATCH_STATUS                                       CHAR(1)
# STAT_MESSAGE                                       VARCHAR2(160)
