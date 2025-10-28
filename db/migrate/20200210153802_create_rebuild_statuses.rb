# frozen_string_literal: true

class CreateRebuildStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :rebuild_statuses do |t|
      t.integer :display_rebuild_id
      t.integer :in_progress_rebuild_id

      t.timestamps
    end
  end
end
