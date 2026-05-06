 module TbcorpUtils
    def self.populate_employee_users
      Employee.using(Rails.configuration.util_schema).active.each do |emp|  # employees are in master, doesn't matter which schema we use
        user=User.using('pg').host_users.find_by_empno(emp.empno)
        if user
          user.name = emp.name
          user.save
          puts "Updated user #{user.name}"
        else
          user=User.using('pg').new
          user.email="#{emp.empno}@tb.local"
          user.empno = emp.empno
          user.name = emp.name
          user.user_type = User::HOST
          user.password = "#{emp.empno}login"
          user.password_confirmation  =  "#{emp.empno}login"
          user.locale = 'en'
          user.save
          puts "Created user for #{user.name}"
        end

      end
    end

    def self.purge_binpick_batches_for_client(client)
      BinpickBatch.for_purge.each do |batch|
        puts "Removing batch #{batch.id} for #{client.username}"
        BinpickOrder.using(client.username).for_batch(batch.id) do |order|
          order.destroy
        end
        BinpickBin.using(client.username).for_batch(batch.id) do |bin|
          bin.destroy
        end
        batch.destroy
      end

    end

    def self.purge_closed_binpick_batches
      Client.all.each do |client|
        puts "Processing client #{client.username}"
        purge_binpick_batches_for_client(client)
      end

    end

    def self.copy_receipt_batches
      ReceiptBatch.using('tbdash').where('id > ?',7859).each do |batch|
        old_client = batch.client
        next if old_client.nil?
        new_client = Client.using('pg').find_by_username(old_client.username)
        puts "No corresponding client for #{old_client.username}" if new_client.nil?
        next if new_client.nil?
        puts "client = #{new_client.username}"
        new_batch = ReceiptBatch.using('pg').new(batch.attributes)
        new_batch.client_id = new_client.id
        new_batch.id = nil
        puts "Batch header = #{new_batch.inspect}"
        new_batch.using('pg').save
        new_batch.reload
        batch.receipt_items.each do |item|
          new_item = ReceiptItem.using('pg').new(item.attributes)
          new_item.receipt_batch_id = new_batch.id
          new_item.id = nil
          puts "Receipt item = #{new_item.inspect}"
          next unless new_item.using('pg').save
          new_item.reload
          item.receipt_locations.each do |location|
            new_location = ReceiptLocation.using('pg').new(location.attributes)
            new_location.receipt_item_id = new_item.id
            new_location.id = nil
            puts "receipt location = #{new_location.inspect}"
            next unless new_location.using('pg').save
          end
        end
        new_batch.reload
        new_batch.batch_status = batch.batch_status
        new_batch.save
      end

    end

  end
