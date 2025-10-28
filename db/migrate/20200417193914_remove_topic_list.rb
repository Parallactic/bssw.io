# frozen_string_literal: true

class RemoveTopicList < ActiveRecord::Migration[5.0]
  def change
    remove_column :site_items, :topic_list
  end
end
