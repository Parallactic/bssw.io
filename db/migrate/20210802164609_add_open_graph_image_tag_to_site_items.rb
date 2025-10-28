class AddOpenGraphImageTagToSiteItems < ActiveRecord::Migration[6.0]
  def change
    add_column :site_items, :open_graph_image_tag, :string
  end
end
