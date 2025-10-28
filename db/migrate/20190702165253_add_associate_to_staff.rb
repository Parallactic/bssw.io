# frozen_string_literal: true

class AddAssociateToStaff < ActiveRecord::Migration[5.0]
  def change
    add_column :authors, :associate, :boolean, default: false
  end
end
