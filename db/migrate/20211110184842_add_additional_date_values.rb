class AddAdditionalDateValues < ActiveRecord::Migration[6.0]
  def change
    create_table :additional_date_values do |t|
      t.datetime :date
      t.integer :additional_date_id
      t.timestamps
    end
  end
end
