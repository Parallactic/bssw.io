class AddUnpublishedToLog < ActiveRecord::Migration[7.0]
  def change
    add_column :rebuilds, :unpublished_files, :text
  end
end
