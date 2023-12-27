class AddRebuildId < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :rebuild_id, :integer
  end
end
