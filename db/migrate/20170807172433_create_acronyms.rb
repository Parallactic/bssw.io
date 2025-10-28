# frozen_string_literal: true

class CreateAcronyms < ActiveRecord::Migration[5.0]
  def change
    create_table :acronyms do |t|
      t.column :name, :string
      t.timestamps
    end
  end
end
