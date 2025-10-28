# frozen_string_literal: true

class AddSlugsToFellow < ActiveRecord::Migration[5.0]
  def change
    add_column :fellows, :slug, :string
  end
end
