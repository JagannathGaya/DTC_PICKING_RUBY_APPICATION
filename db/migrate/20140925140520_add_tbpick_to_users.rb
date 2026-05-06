class AddTbpickToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string
    add_column :users, :empno, :string
    add_column :users, :time_zone, :string
    add_column :users, :locale, :string
    add_column :users, :user_type, :string, default: 'user'
    add_column :users, :lock_version, :integer, default: 0, null: false
  end
end
