# frozen_string_literal: true

class CreateFellows < ActiveRecord::Migration[5.0]
  def change
    create_table :fellows do |t|
      t.string :year
      t.string :name
      t.string :affiliation
      t.string :image_path
      t.string :url
      t.string :linked_in
      t.string :github
      t.string :short_bio
      t.string :long_bio

      t.timestamps
    end
  end
end
