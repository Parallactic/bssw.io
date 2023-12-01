class AddTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :tracks do |t|
      t.string :name
    end
    create_join_table :tracks, :site_items do |t|
      t.index %i[site_item_id track_id]
    end

  end
end
