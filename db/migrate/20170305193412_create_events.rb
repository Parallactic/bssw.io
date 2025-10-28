# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name
      t.date :start_at
      t.date :end_at
      t.string :location
      t.string :website
      t.text :content
      t.timestamps
    end
  end
end
