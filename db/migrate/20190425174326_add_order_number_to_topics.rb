# frozen_string_literal: true

class AddOrderNumberToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :order_num, :integer
  end
end
