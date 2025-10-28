# frozen_string_literal: true

class AddOrderFields < ActiveRecord::Migration[5.0]
  def change
    add_column :contributions, :order, :integer, default: 1
    add_column :subresource_relations, :order, :integer, default: 1
    add_column :features, :order, :integer, default: 1
  end
end
