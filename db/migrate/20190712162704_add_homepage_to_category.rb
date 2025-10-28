# frozen_string_literal: true

class AddHomepageToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :homepage, :text
  end
end
