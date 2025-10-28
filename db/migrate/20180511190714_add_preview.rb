# frozen_string_literal: true

class AddPreview < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :preview, :boolean, default: false
  end
end
