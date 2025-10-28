# frozen_string_literal: true

class SiteItemId < ActiveRecord::Migration[5.0]
  def change
    rename_column :contributions, :resource_id, :site_item_id
  end
end
