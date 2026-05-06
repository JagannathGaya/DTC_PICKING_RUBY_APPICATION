class BinpickEmpClientSum < TbpView
  self.table_name = 'tb_ff_tbpick_emp_client_vw'
  self.primary_key = 'empno'

  scope :for_client, -> (schema) {where(ff_schema: schema)}
  scope :for_employee, -> (empno) {where(empno: empno)}
  scope :ordered, -> {order(:work_date, :ff_schema)}

end