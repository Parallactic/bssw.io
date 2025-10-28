# frozen_string_literal: true

class ChangeFiltersToTopics < ActiveRecord::Migration[5.0]
  def change
    rename_table :filters, :topics
  end
end
