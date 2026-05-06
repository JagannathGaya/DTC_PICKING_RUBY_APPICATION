class Admin::PageRequestsController < Admin::HomeController
  before_action :authorize_admin!

  def index
    get_lovs
    @page_requests = PageRequest.all
                                .filter_by_column(:controller, filter('pr_controller_filter'), t(:all))
                                .filter_by_column(:action, filter('pr_action_filter'), t(:all))
                                .filter_by_column(:format, filter('pr_format_filter'), t(:all))
                                .filter_by_column(:method, filter('pr_method_filter'), t(:all))
                                .filter_by_column(:status, filter('pr_status_filter'), t(:all))
                                .filter_by_qty_gt_than(:page_runtime, filter('pr_page_runtime_filter'))
                                .filter_by_qty_gt_than(:view_runtime, filter('pr_view_runtime_filter'))
                                .filter_by_qty_gt_than(:db_runtime, filter('pr_db_runtime_filter'))
                                .order(id: :desc).page(params[:page]).per(page_size)
  end

  def method_hits
    sql = %{select method, action_date, action_hour, count(1) as hit_count, sum(page_runtime)/count(1) as page_time
from page_requests
where created_at > current_date - 7
group by method, action_date, action_hour
order by hit_count desc}
    hits = PageRequest.find_by_sql(sql)
    @method_hits = hits.take(8).collect { |hour|  ["#{hour.action_date} #{hour.action_hour.to_s} #{hour.method}", hour.hit_count, hour.page_time.round(2).to_s]} #, hour.page_time.round(2).to_s]}
    # @method_hits.unshift ['Hour Method', 'Hits', { role: 'annotation' }]
    # puts "PROCESSED: #{@method_hits.to_s}"

  end

  def db_runtimes
    sql = %{select controller, action, count(1) as hit_count, sum(db_runtime)/count(1) as db_avg_time
from page_requests
where created_at > current_date - 7
group by controller, action
order by db_avg_time desc}
    data = PageRequest.find_by_sql(sql)
    @db_times = data.take(8).collect { |row|  ["#{row.action}", row.db_avg_time.round(3).to_f, "#{row.controller.sub('Controller','')}(#{row.hit_count.to_s})"]}
    # puts "PROCESSED: #{@db_times.to_s}"
  end

  private

  def get_lovs
    @controllers = PageRequest.pluck('controller').uniq.compact.sort.unshift(t(:all))
    @actions = PageRequest.pluck('action').uniq.compact.sort.unshift(t(:all))
    @formats = PageRequest.pluck('format').uniq.compact.sort.unshift(t(:all))
    @methods = PageRequest.pluck('method').uniq.compact.sort.unshift(t(:all))
    @statuses = PageRequest.pluck('status').uniq.compact.sort.unshift(t(:all))
  end

end