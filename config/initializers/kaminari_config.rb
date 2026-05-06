Kaminari.configure do |config|
  config.default_per_page = 50
  # config.max_per_page = nil
  # config.max_pages = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  # config.params_on_first_page = false
end

# module Kaminari
#   module Helpers
#     class Paginator
#       def render(&block)
#         instance_eval(&block) if @options[:total_pages] >= 1
#         @output_buffer
#       end
#     end
#   end
# end
