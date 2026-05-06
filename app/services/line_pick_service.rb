class LinePickService

  def initialize(pick, params)
    @pick = pick
    @params = params
  end

  def process
    # puts "*1* #{params.inspect} #{@pick.inspect}"
    if @pick && @params
      if @params[:pick] == 'true'
        @pick.actual_qty = if @pick.pick_type == 'pick'
                             @params[:actual_qty].to_i == 0 ? @pick.pick_qty : [@params[:actual_qty].to_i, @pick.pick_qty.to_i].min
                           else # 'bulk'
                             @params[:actual_qty].to_i == 0 ? @pick.pick_qty : @params[:actual_qty].to_i
                           end
      else
        @pick.actual_qty = 0
      end
      # puts "*2* #{params.inspect} #{@pick.inspect}"
      @pick.save!
    end
    @pick
  end

end