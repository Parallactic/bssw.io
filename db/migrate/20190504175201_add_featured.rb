# frozen_string_literal: true

class AddFeatured < ActiveRecord::Migration[5.0]
  def change
    add_column :site_items, :featured, :integer, default: 0
  end
end
