# frozen_string_literal: true

class AddMoreIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :topics, :rebuild_id
    add_index :authors, :rebuild_id
    add_index :topics, :name
    add_index :contributions, :site_item_id
    add_index :contributions, :author_id
  end
end
