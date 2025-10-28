# frozen_string_literal: true

class ChangeHeroImageCaption < ActiveRecord::Migration[5.0]
  def change
    change_column :site_items, :hero_image_caption, :text
  end
end
