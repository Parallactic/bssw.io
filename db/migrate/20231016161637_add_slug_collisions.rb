class AddSlugCollisions < ActiveRecord::Migration[7.0]
  def change
    add_column :rebuilds, :slug_collisions, :text
  end
end
