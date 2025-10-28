# frozen_string_literal: true

class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.text :overview
      t.text :content

      t.timestamps
    end
  end
end
