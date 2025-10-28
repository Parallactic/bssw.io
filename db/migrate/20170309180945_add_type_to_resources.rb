# frozen_string_literal: true

class AddTypeToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :type, :string
  end
end
