# frozen_string_literal: true

class AddOverviewAndQuoteToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :overview, :text
    add_column :categories, :quote, :text
  end
end
