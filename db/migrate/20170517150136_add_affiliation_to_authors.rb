# frozen_string_literal: true

class AddAffiliationToAuthors < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :affiliation, :string
  end
end
