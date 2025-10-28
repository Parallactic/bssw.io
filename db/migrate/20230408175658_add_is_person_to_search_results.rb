class AddIsPersonToSearchResults < ActiveRecord::Migration[7.0]
  def change
    add_column :search_results, :is_person, :boolean, :default => false
  end
end
