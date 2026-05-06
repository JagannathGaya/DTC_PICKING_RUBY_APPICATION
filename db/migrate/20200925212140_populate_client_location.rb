class PopulateClientLocation < ActiveRecord::Migration[6.0]
  def up
    Client.all.each do |client|
      sls_loc = TbdashSalesLoc.using(client.cust_no).ordered.first
      if sls_loc
        puts "Processing client #{client.cust_no} adding #{sls_loc.sls_location}"
        client.client_locations << ClientLocation.new(sls_location: sls_loc.sls_location, name: sls_loc.name)
      else
        puts "Processing client #{client.cust_no} No locations"
      end
    end
  end

  def down
    Client.all.each do |client|
      client.client_locations.destroy_all
    end
  end
end
