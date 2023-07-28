class AddNamesToRebuilds < ActiveRecord::Migration[7.0]
  def change
    add_column :rebuilds, :names, :text
  end
end
