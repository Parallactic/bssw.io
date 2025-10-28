# frozen_string_literal: true

class AddRebuildIdToSiteItems < ActiveRecord::Migration[5.0]
  def change
    add_column :site_items, :rebuild_id, :integer
  end
end
