class AddBoOptionToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :allow_combined, :boolean, default: true, null: false
  end
end
