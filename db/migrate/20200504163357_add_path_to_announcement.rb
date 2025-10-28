# frozen_string_literal: true

class AddPathToAnnouncement < ActiveRecord::Migration[5.0]
  def change
    add_column :announcements, :path, :string
  end
end
