# frozen_string_literal: true

class CreateContributions < ActiveRecord::Migration[5.0]
  def change
    create_table :contributions do |t|
      t.integer :author_id
      t.integer :resource_id

      t.timestamps
    end
  end
end
