# frozen_string_literal: true

class CreateFeatures < ActiveRecord::Migration[5.0]
  def change
    create_table :features do |t|
      t.integer :resource_id
      t.integer :community_id

      t.timestamps
    end
  end
end
