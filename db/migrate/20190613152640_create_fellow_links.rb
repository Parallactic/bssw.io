# frozen_string_literal: true

class CreateFellowLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :fellow_links do |t|
      t.integer :fellow_id
      t.string :url
      t.string :text

      t.timestamps
    end
  end
end
