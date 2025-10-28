# frozen_string_literal: true

class CreateAnnouncements < ActiveRecord::Migration[5.0]
  def change
    create_table :announcements do |t|
      t.date :start_date
      t.date :end_date
      t.text :text

      t.timestamps
    end
  end
end
