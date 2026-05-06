module LogRequestHelper

  def logfile_filter
    select_tag 'logfile_filter',
               options_for_select(@logfiles.unshift(t(:all)), session[:filter]['logfile_filter'])
  end

end