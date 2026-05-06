# require ::Rails.root.join 'lib', 'tbcorp_utils.rb'
namespace :tbcorp do

  desc "Remove closed and canceled binpick batches over 2 weeks old"
  task :age_off_binpick_batches=> :environment do
    BinpickBatchPurgeService.new.age_them_off
  end
  
end