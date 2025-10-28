# frozen_string_literal: true

class CreateFilters < ActiveRecord::Migration[5.0]
  def change
    create_table :filters do |t|
      t.string :name
      t.timestamps
    end
    create_table :filters_resources do |t|
      t.references :filter, :resource
    end
  end
end
