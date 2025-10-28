# frozen_string_literal: true

class AddPathToCommunities < ActiveRecord::Migration[5.0]
  def change
    add_column :communities, :path, :string
  end
end
