class BinpickEmpSum < TbpView
  self.table_name = 'tb_ff_tbpick_emp_sum_vw'
  self.primary_key = 'empno'

  scope :ordered, -> {order(work_date: :desc , empno: :asc)}


end