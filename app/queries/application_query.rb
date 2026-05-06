# frozen_string_literal: true

class ApplicationQuery

  private

  def filter(value)
    params[value] || filters[value]
  end

end