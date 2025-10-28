class AddBasePath < ActiveRecord::Migration[6.0]
  def change
    add_column :site_items, :base_path, :string
    add_column :communities, :base_path, :string
    add_column :categories, :base_path, :string
    add_column :pages, :base_path, :string
    add_column :fellows, :base_path, :string
  end
end
