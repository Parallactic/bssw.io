# frozen_string_literal: true

class AddPathToFellows < ActiveRecord::Migration[5.0]
  def change
    add_column :fellows, :path, :string
  end
end
