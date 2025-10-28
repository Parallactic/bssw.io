# frozen_string_literal: true

class AddPublish < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :publish, :boolean, default: false
    add_column :events, :publish, :boolean, default: false
  end
end
