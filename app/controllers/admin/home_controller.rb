class Admin::HomeController < ApplicationController
  around_action :set_pg_shard
  before_action :ensure_minimum_admin_filter

  def index
  end

end
