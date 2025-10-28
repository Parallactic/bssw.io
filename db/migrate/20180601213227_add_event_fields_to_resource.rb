# frozen_string_literal: true

class AddEventFieldsToResource < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :location, :string
    add_column :resources, :website, :string
    add_column :resources, :organizers, :string
    add_column :resources, :end_at, :date
    add_column :resources, :start_at, :date
    drop_table :events
  end
end
