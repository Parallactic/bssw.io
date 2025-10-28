# frozen_string_literal: true

class AddOverviewAndDescriptionToTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :overview, :text
    add_column :topics, :description, :text
  end
end
