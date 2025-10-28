# frozen_string_literal: true

class AddSlugToCommunity < ActiveRecord::Migration[5.0]
  def change
    add_column :communities, :slug, :string
    add_index :communities, :slug, unique: true
  end
end
