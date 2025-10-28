# frozen_string_literal: true

class CreateFeaturedPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :featured_posts do |t|
      t.string :label
      t.string :path
    end
  end
end
