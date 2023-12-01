class AddListedToTracks < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :listed, :boolean, default: false
  end
end
