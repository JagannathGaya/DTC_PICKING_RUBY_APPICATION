class TbdashItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_minimum_filter

   def item_comments
    puts "TbdashItemsController#get_item_comments params = #{params}"
    return [] if params[:item_no].nil?
    comments = TbdashItemComment.using(@current_client.cust_no).where(item_no: params[:item_no]).for_type('RE')
    # puts "comments result = #{comments.inspect}"
    @item_comments = {comment_text: comments.nil? ? '' : comments.pluck(:comment_text).join(' ')}
    # puts "#{@item_comments.inspect}"
  end

  private

end