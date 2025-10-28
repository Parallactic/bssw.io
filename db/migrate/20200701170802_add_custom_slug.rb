# frozen_string_literal: true

class AddCustomSlug < ActiveRecord::Migration[5.0]
  def change
    add_column :site_items, :custom_slug, :string
  end
end
