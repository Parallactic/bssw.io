# frozen_string_literal: true

class AddSearchTextToFellows < ActiveRecord::Migration[5.0]
  def change
    add_column :fellows, :search_text, :text
  end
end
