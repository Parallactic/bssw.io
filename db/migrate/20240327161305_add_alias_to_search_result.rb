class AddAliasToSearchResult < ActiveRecord::Migration[7.0]
  def change
    add_column :site_items, :alias, :string
  end
end
