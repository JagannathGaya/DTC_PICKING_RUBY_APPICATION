class PopLocInBinpickBatch < ActiveRecord::Migration[6.0]
  class BinpickBatch < ActiveRecord::Base

  end

  def up
    BinpickBatch.all.each do |bb|
      puts "#{bb.client_id.inspect} "
      client = Client.find bb.client_id
      bb.client_location_id = client.client_locations.first&.id
      puts "#{bb.client_id.inspect} #{bb.client_location_id.inspect}"
      bb.save!
    end
  end
end
