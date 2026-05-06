class BinpickOracleService

  BATCH_PROCESS = 'P'
  BATCH_OPEN = 'O'
  BATCH_CONFIRMED = 'S'
  PICKED_COMPLETE = 'K'

  def initialize(client_id, sls_location, binpick_batch_id)
    @client_id = client_id
    @sls_location = sls_location
    @binpick_batch_id = binpick_batch_id
    # puts "BinpickOracleService #{@sls_location.inspect}"
  end

  def make_in_oracle
    @client = Client.using('pg').find(@client_id)
    @binpick_batch = BinpickBatch.using('pg').find(@binpick_batch_id)
    BinpickBatchProcessor.transaction do
      BinpickBatch.transaction do
        binpick_batch_processor = BinpickBatchProcessor.using(@client.cust_no).new
        binpick_batch_processor.nds_number = 1 # fool Activerecord into not including a RETURNING clause
        binpick_batch_processor.sls_location = @sls_location
        binpick_batch_processor.binpick_batch_id = @binpick_batch.id
        binpick_batch_processor.start_order_seq = @binpick_batch.start_order_seq
        binpick_batch_processor.bo_option = @binpick_batch.bo_option
        binpick_batch_processor.action = BATCH_PROCESS
        # puts "BinpickOracleService #{binpick_batch_processor.inspect}"
        binpick_batch_processor.save!
        # binpick_batch_processor.reload
        binpick_batch_control = BinpickBatchControl.using(@client.cust_no).where(sls_location: @sls_location, bo_option:@binpick_batch.bo_option).first
        @binpick_batch.status = BATCH_OPEN
        @binpick_batch.end_order_seq = binpick_batch_control&.end_order_seq
        @binpick_batch.save!
      end
    end
#  rescue ActiveRecord::ActiveRecordError => e
#    ErrorMailService.new(e, caller_locations.first).report
#    raise
  end

  def complete_pick_in_oracle
    @client = Client.using('pg').find(@client_id)
    @binpick_batch = BinpickBatch.using('pg').find(@binpick_batch_id)
    BinpickBatchProcessor.transaction do
      BinpickBatch.transaction do
        binpick_batch_processor = BinpickBatchProcessor.using(@client.cust_no).new
        binpick_batch_processor.nds_number = 1  # fool Activerecord into not including a RETURNING clause
        binpick_batch_processor.sls_location = @sls_location
        binpick_batch_processor.binpick_batch_id = @binpick_batch.id
        binpick_batch_processor.bo_option = @binpick_batch.bo_option
        binpick_batch_processor.action = BATCH_CONFIRMED
        binpick_batch_processor.save!
        @binpick_batch.status = PICKED_COMPLETE
        @binpick_batch.pack_complete_at = DateTime.now
        @binpick_batch.save!
      end
    end
    #rescue ActiveRecord::ActiveRecordError => e
    # ErrorMailService.new(e, caller_locations.first).report
    #raise
  end

end

