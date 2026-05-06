# require ::Rails.root.join 'lib', 'tbcorp_utils.rb'
namespace :tbcorp do

  desc "Remove closed binpick batches over 1 week old"
  task :purge_binpick_batches=> :environment do
    TbcorpUtils.purge_closed_binpick_batches
  end
  
end