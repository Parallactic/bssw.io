# frozen_string_literal: true

class ChangeTitleToName < ActiveRecord::Migration[5.0]
  def change
    rename_column :resources, :title, :name
    rename_column :pages, :title, :name
  end
end
