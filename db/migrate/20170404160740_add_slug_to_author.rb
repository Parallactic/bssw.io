# frozen_string_literal: true

class AddSlugToAuthor < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :slug, :string
    add_index :authors, :slug, unique: true
  end
end
