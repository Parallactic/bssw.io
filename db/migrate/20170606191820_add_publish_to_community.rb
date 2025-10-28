# frozen_string_literal: true

class AddPublishToCommunity < ActiveRecord::Migration[5.0]
  def change
    add_column :communities, :publish, :boolean
  end
end
