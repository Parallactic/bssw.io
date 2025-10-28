# frozen_string_literal: true

class AlterSubresourceRelations < ActiveRecord::Migration[5.0]
  def change
    remove_column :subresource_relations, :resource_id
    add_column :subresource_relations, :parent_resource_id, :integer
  end
end
