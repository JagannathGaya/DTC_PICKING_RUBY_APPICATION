# frozen_string_literal: true

require 'test_helper'

class PageRequestsServiceTest < ActiveSupport::TestCase
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  test 'Reshedule the purge' do
    assert_difference('DelayedJob.count', +1) do
      result = PageRequestsService.new(Date.today).schedule_another
      assert result
    end
  end

  test 'Run the purge and reschedule' do
    assert_difference('DelayedJob.count', +1) do
      assert_difference('PageRequest.count', -1) do
      result = PageRequestsService.new(Date.today).age_them_off
      assert result
      end
    end
  end

end
