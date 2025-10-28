# frozen_string_literal: true

class AddHonorableMentionToFellows < ActiveRecord::Migration[5.0]
  def change
    add_column :fellows, :honorable_mention, :boolean, default: false
  end
end
