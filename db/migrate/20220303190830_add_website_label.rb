class AddWebsiteLabel < ActiveRecord::Migration[6.0]
  def change
    add_column :site_items, :website_label, :string
  end
end
