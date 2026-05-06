class TbdashClientGlobal < TbpView

  EXCLUDE_COLUMNS = []

  self.table_name = 'tbdash_client_global_vw'
  self.primary_key = 'cust_no'

  def self.receiving_note(cust_no)
    res = TbdashClientGlobal.using(cust_no).first
    res ? res.receiving_comments : nil
  end

end

