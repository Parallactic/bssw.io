# frozen_string_literal: true

class AddLogsToRebuild < ActiveRecord::Migration[6.0]
  def change
    add_column :rebuilds, :files_processed, :text
    add_column :rebuilds, :errors_encountered, :text
  end
end
