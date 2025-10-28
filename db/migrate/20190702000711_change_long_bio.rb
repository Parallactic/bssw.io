# frozen_string_literal: true

class ChangeLongBio < ActiveRecord::Migration[5.0]
  def change
    change_column :fellows, :long_bio, :text
  end
end
