class AddMgrEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :clients,:client_manager_email, :string
  end
end
