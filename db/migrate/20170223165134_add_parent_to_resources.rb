# frozen_string_literal: true

class AddParentToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :parent_id, :integer
  end
end
