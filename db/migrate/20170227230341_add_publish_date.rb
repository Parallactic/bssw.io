# frozen_string_literal: true

class AddPublishDate < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :published_at, :datetime
  end
end
