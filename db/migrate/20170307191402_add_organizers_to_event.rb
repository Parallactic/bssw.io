# frozen_string_literal: true

class AddOrganizersToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :organizers, :text
  end
end
