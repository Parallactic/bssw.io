# frozen_string_literal: true

class AddSearchText < ActiveRecord::Migration[5.0]
  def change
    add_column :site_items, :search_text, :text
  end
end
