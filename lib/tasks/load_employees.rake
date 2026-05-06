# require ::Rails.root.join 'lib', 'tbcorp_utils.rb'
namespace :tbcorp do

  desc "Create / update HOST users based on NDS employee table "
  task :load_employees=> :environment do
    TbcorpUtils.populate_employee_users
  end
  
end