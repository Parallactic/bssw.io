# frozen_string_literal: true

class AddBasicsToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :what_is_id, :integer
    add_column :categories, :how_to_id, :integer
  end
end
