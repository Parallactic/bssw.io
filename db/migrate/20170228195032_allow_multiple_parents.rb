# frozen_string_literal: true

class AllowMultipleParents < ActiveRecord::Migration[5.0]
  def change
    remove_column :resources, :parent_id
    create_table :children_parents do |t|
      t.column :parent_id, :integer
      t.column :child_id, :integer
    end
  end
end
