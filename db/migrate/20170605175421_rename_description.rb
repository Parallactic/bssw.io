# frozen_string_literal: true

class RenameDescription < ActiveRecord::Migration[5.0]
  def change
    rename_column :categories, :description, :content
    rename_column :communities, :description, :content
  end
end
