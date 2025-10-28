class RemoveDates < ActiveRecord::Migration[6.0]
  def change
    remove_column :site_items, :start_at
    remove_column :site_items, :end_at
    remove_column :additional_dates, :start_at
    remove_column :additional_dates, :end_at
    remove_column :additional_dates, :text
  end
end
