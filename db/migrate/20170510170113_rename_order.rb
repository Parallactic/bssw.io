# frozen_string_literal: true

class RenameOrder < ActiveRecord::Migration[5.0]
  def change
    rename_column :categories, :order, :order_num
  end
end
