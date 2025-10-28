# frozen_string_literal: true

class ResourcesTopics < ActiveRecord::Migration[5.0]
  def change
    rename_table :filters_resources, :resources_topics
    rename_column :resources_topics, :filter_id, :topic_id
  end
end
