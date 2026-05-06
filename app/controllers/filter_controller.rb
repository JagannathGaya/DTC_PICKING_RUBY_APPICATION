class FilterController < ApplicationController
  before_action :set_filter
  after_action :update_session

  def update
    redirector = params[:redirect_to].partition('?page')[0]
    params.each do |key, value|
      @filters[key.to_sym] = value
      if key == 'client_id'
        redirector = root_url
        @filters = {}
        session[:filter] = {}
        session[:orderlist] = String.new
        case value[0]
        when 'L'
          @current_client_location = ClientLocation.using('pg').find(value[1..99])
          @current_client = @current_client_location.client
          @filters[:client_id] = @current_client_location.client_id
          @filters[:client_location_id] = @current_client_location.id
        when 'C'
          @current_client_location = nil
          @current_client = Client.using('pg').find(value[1..99])
          @filters[:client_id] = @current_client.id
        else
          @current_client = nil
          @current_client_location = nil
        end
        session[:filter] = @filters
      end
    end
    render :json => {"new_url" => redirector}
  end

  def clear
    if params[:method] == 'delete'
      if session[:sortkey]
        session[:sortdir] = session[:sortdir] == 'asc' ? 'desc' : 'asc'
      else
        session[:sortkey] = params[:column]
        session[:sortdir] = 'asc'
      end
    else
      clear_filters
      session[:sortkey] = nil
      session[:sortdir] = nil
    end
    redirect_url = params.delete(:redirect_to) || root_url
    redirect_to redirect_url, :only_path => true
  end

  def sorter
    # mystery to solve: need this but it gets routed to #clear, because action is ignored
  end


  private

  def set_filter
    @filters = session[:filter] || {}
  end

  def update_session
    session[:filter] = @filters
    # puts "SETTING SESSION #{session[:filter].inspect}"
  end
end