# frozen_string_literal: true

class AddResourceIdToAnnouncement < ActiveRecord::Migration[5.0]
  def change
    add_column :announcements, :resource_id, :integer
  end
end
