# frozen_string_literal: true

class AddAvatarToAuthor < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :avatar_url, :string
  end
end
