# frozen_string_literal: true

class SiteItemsAssociationTables < ActiveRecord::Migration[5.0]
  def change
    create_table :site_items_topics do |t|
      t.column :topic_id, :integer
      t.column :site_item_id, :integer
    end
  end
end
