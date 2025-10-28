# frozen_string_literal: true

class AddHeroImageUrlToBlogPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :hero_image_url, :string
    add_column :resources, :hero_image_caption, :string
  end
end
