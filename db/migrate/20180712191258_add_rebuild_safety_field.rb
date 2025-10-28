# frozen_string_literal: true

class AddRebuildSafetyField < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :cached_during_rebuild, :boolean, default: false
    add_column :communities, :cached_during_rebuild, :boolean, default: false
    add_column :categories, :cached_during_rebuild, :boolean, default: false
    add_column :topics, :cached_during_rebuild, :boolean, default: false
    add_column :announcements, :cached_during_rebuild, :boolean, default: false
    add_column :authors, :cached_during_rebuild, :boolean, default: false

    add_column :quotes, :cached_during_rebuild, :boolean, default: false
    add_column :pages, :cached_during_rebuild, :boolean, default: false
  end
end
