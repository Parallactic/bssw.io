# frozen_string_literal: true

class AddPathToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :path, :text
  end
end
