class AddOpenGraphImageTagToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :open_graph_image_tag, :string
  end
end
