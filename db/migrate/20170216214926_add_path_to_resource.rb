# frozen_string_literal: true

class AddPathToResource < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :path, :string
  end
end
