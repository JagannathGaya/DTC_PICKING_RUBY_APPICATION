class Employee < TbpView
  self.table_name = 'tbpick_employee_vw'
  self.primary_key = 'empno'

  scope :active, -> { where(emp_status: 'A')}

end