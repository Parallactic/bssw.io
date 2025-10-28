# frozen_string_literal: true

class AddSlugToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :slug, :string
  end
end
