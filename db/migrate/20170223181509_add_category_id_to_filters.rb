# frozen_string_literal: true

class AddCategoryIdToFilters < ActiveRecord::Migration[5.0]
  def change
    add_column :filters, :category_id, :integer
  end
end
