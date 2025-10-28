# frozen_string_literal: true

class CreateRebuilds < ActiveRecord::Migration[5.0]
  def change
    create_table :rebuilds do |t|
      t.string :ip
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
