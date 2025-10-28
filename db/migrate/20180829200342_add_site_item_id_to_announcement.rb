# frozen_string_literal: true

class AddSiteItemIdToAnnouncement < ActiveRecord::Migration[5.0]
  def change
    add_column :announcements, :site_item_id, :integer
  end
end
