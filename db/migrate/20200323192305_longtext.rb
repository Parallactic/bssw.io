# frozen_string_literal: true

class Longtext < ActiveRecord::Migration[5.0]
  def change
    change_column :site_items, :content, :text, limit: 4_294_967_295
  end
end
