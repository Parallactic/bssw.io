# frozen_string_literal: true

class ChangeTopicList < ActiveRecord::Migration[5.0]
  def change
    change_column :site_items, :topic_list, :text
  end
end
