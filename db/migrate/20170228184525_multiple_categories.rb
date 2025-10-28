# frozen_string_literal: true

class MultipleCategories < ActiveRecord::Migration[5.0]
  def change
    remove_column :resources, :category_id
    create_table :categories_resources do |t|
      t.column :category_id, :integer
      t.column :resource_id, :integer
    end
  end
end
