# frozen_string_literal: true

class AddTitleToStaff < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :title, :string
  end
end
