# frozen_string_literal: true

class AddFieldsToAuthors < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :first_name, :string
    add_column :authors, :last_name, :string
  end
end
