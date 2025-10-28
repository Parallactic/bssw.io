# frozen_string_literal: true

class AddFieldsToAuthor < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :resource_count, :integer
    add_column :authors, :blog_count, :integer
    add_column :authors, :event_count, :integer
    add_column :authors, :resource_listing, :string
    add_column :authors, :event_listing, :string
    add_column :authors, :blog_listing, :string
  end
end
