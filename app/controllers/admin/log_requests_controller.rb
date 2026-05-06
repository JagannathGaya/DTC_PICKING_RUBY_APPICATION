class Admin::LogRequestsController < Admin::HomeController
  before_action :authorize_admin!

  def index
    logname = Rails.root.join('log', Rails.env + '.log')
    log = File.new(logname)
    size = File.size?(log)
    if size
      if size > 15000
        log.seek(-15000, IO::SEEK_END)
      else
        log.seek(-size, IO::SEEK_END)
      end
      @lines = log.readlines
    else
      @lines = [logname, 'Empty log file']
    end
  end

  def routing_failures
    if params[:page].blank? || (params[:page] && params[:page] == "1")
      RoutingFailure.delete_all
      Rails.application.config.logfiles.each do |logfile|
        if File.exist?(logfile)
          logfilter = filter('logfile_filter')
          if ( logfilter.blank? || ( logfilter && (logfilter == t(:all) || logfilter == logfile) ) )
            File.foreach(logfile).grep(/RoutingError/).each do |line|
              logged_at = DateTime.strptime(line.match(/\[(\S+)/)[1], '%Y-%m-%dT%H:%M:%S') rescue nil
              action = line.match(/\[(\S+)\]/)[1] rescue nil
              if action.blank? || action.length < 7
                action = line.match(/(?:.*?\[){1}.*?\[(\S+)\]/)[1] rescue nil
              end
              request = line.match(/\"(\S+)\"/)[1] rescue nil
              RoutingFailure.create(logfile: logfile,
                                    logged_at: logged_at,
                                    action: action,
                                    request: request) if logged_at || request || action
            end
          end
        end
      end
    end
    @logfiles = Rails.application.config.logfiles.dup
    current_size = userset_page_size('routing_failures')
    @routing_failures = RoutingFailure.ordered.page(params[:page]).per(current_size)
  end

end