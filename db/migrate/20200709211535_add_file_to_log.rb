class AddFileToLog < ActiveRecord::Migration[6.0]
  def change
    add_column :routing_failures, :logfile, :string
  end
end
