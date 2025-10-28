# frozen_string_literal: true

class AddLocationToRebuilds < ActiveRecord::Migration[5.0]
  def change
    add_column :rebuilds, :location, :string
  end
end
