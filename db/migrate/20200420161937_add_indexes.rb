# frozen_string_literal: true

class AddIndexes < ActiveRecord::Migration[5.0]
  def change
    change_column :site_items, :path, :string
    add_index :site_items, :path
    add_index :site_items, :name
    change_column :communities, :path, :string
    add_index :communities, :path
    change_column :pages, :path, :string
    add_index :pages, :path
    add_index :site_items, :rebuild_id
    add_index :communities, :rebuild_id
    add_index :pages, :rebuild_id
    add_index :site_items, :type
  end
end
