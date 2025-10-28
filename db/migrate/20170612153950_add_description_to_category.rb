# frozen_string_literal: true

class AddDescriptionToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :description, :text
  end
end
