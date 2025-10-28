# frozen_string_literal: true

class CreateWhatIs < ActiveRecord::Migration[5.0]
  def change
    create_table :what_is do |t|
      t.integer :category_id
      t.text :content
      t.string :title

      t.timestamps
    end
  end
end
