class CreateStaff < ActiveRecord::Migration[6.0]
  def change
    create_table :staffs do |t|
      t.string :name
      t.string :website
      t.timestamps
      t.string :section
      t.string :affiliation
      t.string :first_name
      t.string :last_name
      t.text :search_text
      t.integer :rebuild_id
      t.string :avatar_url
      t.string :title
      t.string :alphabetized_name
    end
  end
end
