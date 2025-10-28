# frozen_string_literal: true

class ChangeDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default(
      'resources',
      'aggregate',
      'base'
    )
  end
end
