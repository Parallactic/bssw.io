# frozen_string_literal: true

class AddRebuildIdToFeaturedPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :featured_posts, :rebuild_id, :integer
  end
end
