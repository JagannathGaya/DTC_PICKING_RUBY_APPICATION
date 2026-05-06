ActiveSupport::Notifications.subscribe /action_controller/ do |name, start, finish, id, payload|
  PageRequest.create! do |page_request|
    page_request.controller = payload[:controller]
    page_request.action = payload[:action]
    page_request.format = payload[:format]
    page_request.method = payload[:method]
    page_request.path = payload[:path]
    page_request.status = payload[:status]
    page_request.page_runtime = (finish - start)
    page_request.view_runtime = (payload[:view_runtime] || 0) / 1000
    page_request.db_runtime = (payload[:db_runtime] || 0) / 1000
    page_request.action_date = Date.today
    page_request.action_hour = Time.now.strftime('%H').to_i
  end unless payload[:controller].blank? || payload[:status].blank?
end
