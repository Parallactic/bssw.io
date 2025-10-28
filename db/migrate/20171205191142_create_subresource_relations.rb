# frozen_string_literal: true

class CreateSubresourceRelations < ActiveRecord::Migration[5.0]
  def change
    create_table :subresource_relations do |t|
      t.integer :resource_id
      t.integer :subresource_id

      t.timestamps
    end
  end
end
