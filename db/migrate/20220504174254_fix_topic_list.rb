class FixTopicList < ActiveRecord::Migration[6.0]
  def change
    change_table :site_items do |t|
      t.change :topic_list, :text
    end
  end
end
