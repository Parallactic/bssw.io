# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[5.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.string :website
      t.timestamps
    end
    create_table :authors_resources do |t|
      t.integer :author_id
      t.integer :resource_id
    end
  end
end
