module PageRequestHelper

  def pr_controller_filter
    select_tag 'pr_controller_filter', options_for_select(@controllers, session[:filter]['pr_controller_filter'])
  end

  def pr_action_filter
    select_tag 'pr_action_filter', options_for_select(@actions, session[:filter]['pr_action_filter'])
  end

  def pr_format_filter
    select_tag 'pr_format_filter', options_for_select(@formats, session[:filter]['pr_format_filter'])
  end

  def pr_method_filter
    select_tag 'pr_method_filter', options_for_select(@methods, session[:filter]['pr_method_filter'])
  end

  def pr_status_filter
    select_tag 'pr_status_filter', options_for_select(@statuses, session[:filter]['pr_status_filter'])
  end

end