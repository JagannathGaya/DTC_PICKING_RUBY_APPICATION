class BinpickEmpSumsController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter
  BINPICK_DATE_FILTER = 'binpick_date_filter'
  BINPICK_EMP_FILTER = 'binpick_emp_filter'

  def index
    redirect_to_root_path and return # Per Jon, don't want users seeing this
    @binpick_emp_sums = BinpickEmpSum.using(@current_client.cust_no).ordered
    @binpick_emp_sums = @binpick_emp_sums.for_date(session[:filter][BINPICK_DATE_FITLER]) unless session[:filter]['BINPICK_DATE_FILTER'].blank?
    @binpick_emp_sums = @binpick_emp_sums.for_date(session[:filter][BINPICK_EMP_FITLER]) unless session[:filter]['BINPICK_EMP_FILTER'].blank?
  end

  def show
    redirect_to root_path and return # per Jon, don't want users seeing this
    @employee = Employee.using(@current_client.cust_no).find(params[:id])
    @binpick_emp_client_sums = BinpickEmpClientSum.for_employee(params[:id]).ordered
  end

end