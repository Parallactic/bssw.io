# frozen_string_literal: true

class CreateSiteItems < ActiveRecord::Migration[5.0]
  def change
    create_table :site_items do |t|
      t.text :overview
      t.text :content
      t.string :path
      t.string :name
      t.datetime :published_at
      t.string :slug
      t.string :type
      t.string :aggregate
      t.boolean :publish, default: false
      t.boolean :preview, default: false
      t.string :hero_image_url
      t.string :hero_image_caption
      t.date :rss_date
      t.string :location
      t.string :website
      t.string :organizers
      t.date :end_at
      t.date :start_at

      t.timestamps
    end
  end
end
