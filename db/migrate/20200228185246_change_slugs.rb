# frozen_string_literal: true

class ChangeSlugs < ActiveRecord::Migration[5.0]
  def change
    remove_index(:friendly_id_slugs, %i[slug sluggable_type scope])
    add_index(:friendly_id_slugs, %i[slug sluggable_type scope])
    remove_column :pages, :slug
    remove_column :site_items, :slug
    remove_column :categories, :slug
    remove_column :topics, :slug
    remove_column :authors, :slug
    remove_column :fellows, :slug
    remove_column :communities, :slug
    add_column :pages, :slug, :string
    add_column :site_items, :slug, :string
    add_column :categories, :slug, :string
    add_column :topics, :slug, :string
    add_column :authors, :slug, :string
    add_column :fellows, :slug, :string
    add_column :communities, :slug, :string
  end
end
