class RoutingFailure < ApplicationRecord

  scope :ordered, -> { order(:logged_at) }


end
