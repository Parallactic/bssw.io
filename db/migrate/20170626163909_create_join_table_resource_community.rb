# frozen_string_literal: true

class CreateJoinTableResourceCommunity < ActiveRecord::Migration[5.0]
  def change
    create_join_table :resources, :communities do |t|
      t.index %i[resource_id community_id]
      t.index %i[community_id resource_id]
    end
  end
end
