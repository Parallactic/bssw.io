class AddAliasToSearchResults < ActiveRecord::Migration[7.0]
  def change
    add_column :search_results, :alias, :string
  end
end
