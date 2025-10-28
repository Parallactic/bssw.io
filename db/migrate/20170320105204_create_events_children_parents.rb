# frozen_string_literal: true

class CreateEventsChildrenParents < ActiveRecord::Migration[5.0]
  def change
    create_table :events_resources do |t|
      t.column :event_id, :integer
      t.column :resource_id, :integer
    end
  end
end
