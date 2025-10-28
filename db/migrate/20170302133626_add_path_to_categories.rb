# frozen_string_literal: true

class AddPathToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :path, :string
  end
end
