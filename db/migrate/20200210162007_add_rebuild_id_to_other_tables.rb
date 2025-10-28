# frozen_string_literal: true

class AddRebuildIdToOtherTables < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :rebuild_id, :integer
    add_column :quotes, :rebuild_id, :integer
    add_column :announcements, :rebuild_id, :integer
    add_column :pages, :rebuild_id, :integer
    add_column :communities, :rebuild_id, :integer
    add_column :categories, :rebuild_id, :integer
    add_column :topics, :rebuild_id, :integer
  end
end
