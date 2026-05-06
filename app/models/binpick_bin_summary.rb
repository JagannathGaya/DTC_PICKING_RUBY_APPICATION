class BinpickBinSummary < TbpView

  self.table_name = 'tbpick_batch_bin_summary_vw'
  self.primary_key = 'id'

  scope :for_batch, -> (batch_id) { where(binpick_batch_id: batch_id) }
  scope :for_status, -> (status) { where("'All' = ? or tbpick_batch_bin_summary_vw.status = ?", status, status)}
  scope :ordered, -> { order(assigned_yn: :desc).order(status: :desc).order(:bin_seq) }
  scope :assigned, -> { where(assigned_yn: 'Y', status: 'Open') }
  scope :completed, -> { where(status: 'Complete') }
  scope :scopen, -> { where("status in ('Open', 'Deferred')").where(assigned_yn: 'N') }
  scope :for_bin_list, -> { where("status in ('Open', 'Deferred', 'Assigned')")
                                .order(Arel.sql("case status when 'Assigned' then 'A' when 'Open' then 'B' else 'C' end"))
                                .order(:bin_seq) }

  STATUS_LIST = %W(Open Assigned Complete Deferred All)
  PICK_TYPES = ['ALL','ALL ORDERS','BIN PICK','WAVE PICK']

end

# BINPICK_BATCH_ID                          NOT NULL NUMBER
# STOCK_AREA                                NOT NULL VARCHAR2(4)
# BIN_LOC                                   NOT NULL VARCHAR2(11)
# AREA_BIN                                      VARCHAR2(51)
# EMPNO_NAME                                      VARCHAR2(51)
# ORDER_COUNT                                        NUMBER
# LINE_COUNT                                         NUMBER
# PICK_QTY                                           NUMBER
# BIN_SEQ                                   NOT NULL NUMBER
# ASSIGNED_YN
# ID                                     CHAR(1)
# STATUS                                             VARCHAR2(8)
# OPEN_LINES                                         NUMBER
# COMPLETED_LINES                                    NUMBER
# BACKORDERED_LINES                                  NUMBER
# PICK_TYPE                                          VARCHAR2(10)
