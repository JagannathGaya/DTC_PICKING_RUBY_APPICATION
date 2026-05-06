class AddDbToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :database, :string
    add_column :clients, :username, :string
    add_column :clients, :password, :string
  end
end
