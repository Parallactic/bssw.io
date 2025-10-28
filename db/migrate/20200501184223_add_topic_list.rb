# frozen_string_literal: true

class AddTopicList < ActiveRecord::Migration[5.0]
  def change
    add_column :site_items, :topic_list, :string
  end
end
