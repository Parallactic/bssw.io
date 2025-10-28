# frozen_string_literal: true

class CreateHowTos < ActiveRecord::Migration[5.0]
  def change
    create_table :how_tos do |t|
      t.integer :category_id
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
