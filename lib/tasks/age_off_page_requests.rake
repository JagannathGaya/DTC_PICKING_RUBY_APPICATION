# require ::Rails.root.join 'lib', 'tbcorp_utils.rb'
namespace :tbcorp do

  desc "Remove page_requests over 2 weeks old"
  task :age_off_page_requests=> :environment do
    PageRequestsService.new(Date.today).age_them_off
  end
  
end