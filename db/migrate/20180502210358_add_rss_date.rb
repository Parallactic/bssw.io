# frozen_string_literal: true

class AddRssDate < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :rss_date, :date
  end
end
