# frozen_string_literal: true

class AddEventAndBlogIdsToAnnouncement < ActiveRecord::Migration[5.0]
  def change
    add_column :announcements, :blog_post_id, :integer
    add_column :announcements, :event_id, :integer
  end
end
