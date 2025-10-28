# frozen_string_literal: true

class AddPathToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :path, :string
  end
end
