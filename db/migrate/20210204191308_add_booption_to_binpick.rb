class AddBooptionToBinpick < ActiveRecord::Migration[6.0]
  def change
    add_column :binpick_batches, :bo_option, :string, default: 'A', null: false
  end
end
