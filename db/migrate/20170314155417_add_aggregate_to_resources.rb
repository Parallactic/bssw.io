# frozen_string_literal: true

class AddAggregateToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :aggregate, :string
  end
end
