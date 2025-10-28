# frozen_string_literal: true

class AddSlugs < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :slug, :string, unique: true
    add_column :resources, :slug, :string, unique: true
    add_column :categories, :slug, :string, unique: true
  end
end
