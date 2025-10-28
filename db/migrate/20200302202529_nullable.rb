# frozen_string_literal: true

class Nullable < ActiveRecord::Migration[5.0]
  def up
    change_column(:contributions, :created_at, :datetime, null: true)
    change_column(:contributions, :updated_at, :datetime, null: true)
  end

  def down
    change_column(:contributions, :created_at, :datetime, null: false)
    change_column(:contributions, :updated_at, :datetime, null: false)
  end
end
