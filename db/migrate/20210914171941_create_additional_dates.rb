class CreateAdditionalDates < ActiveRecord::Migration[6.0]
  def change
    create_table :additional_dates do |t|
      t.string :label
      t.string :text
      t.datetime :start_at
      t.datetime :end_at
      t.integer :event_id
      t.timestamps
    end
  end
end
