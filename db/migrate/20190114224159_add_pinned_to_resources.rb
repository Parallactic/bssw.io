# frozen_string_literal: true

class AddPinnedToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :site_items, :pinned, :boolean, default: false
  end
end
