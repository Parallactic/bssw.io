# frozen_string_literal: true

class AddVersionNo < ActiveRecord::Migration[5.0]
  def change
    add_column :rebuilds, :version_no, :string
    add_column :site_items, :version_no, :string
    add_column :announcements, :version_no, :string
    add_column :topics, :version_no, :string
    add_column :categories, :version_no, :string
    add_column :authors, :version_no, :string
    add_column :communities, :version_no, :string
    add_column :pages, :version_no, :string
    add_column :events, :version_no, :string
    add_column :resources, :version_no, :string
  end
end
