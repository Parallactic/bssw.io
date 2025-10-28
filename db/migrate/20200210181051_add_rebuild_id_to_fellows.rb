# frozen_string_literal: true

class AddRebuildIdToFellows < ActiveRecord::Migration[5.0]
  def change
    add_column :fellows, :rebuild_id, :integer
  end
end
