# frozen_string_literal: true

class AddPathsToCommunities < ActiveRecord::Migration[5.0]
  def change
    add_column :communities, :resource_paths, :text
  end
end
