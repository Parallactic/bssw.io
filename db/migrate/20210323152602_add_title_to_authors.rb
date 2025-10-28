class AddTitleToAuthors < ActiveRecord::Migration[6.0]
  def change
    add_column :authors, :section, :string
  end
end
