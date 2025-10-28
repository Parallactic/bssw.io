class AddSearchTextToAuthors < ActiveRecord::Migration[6.0]
  def change
    add_column :authors, :search_text, :text
  end
end
