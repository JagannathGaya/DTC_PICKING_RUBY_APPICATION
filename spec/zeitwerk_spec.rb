require 'rails_helper'
require 'rake'

RSpec.describe "zeitwerk", type: :system do

  describe "loads classes" do
    it "doesn't fall over" do
      Rails.application.load_tasks
      Rake::Task['zeitwerk:check'].invoke
    end
  end

end
