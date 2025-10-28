# frozen_string_literal: true

class ChangeAuthorList < ActiveRecord::Migration[5.0]
  def change
    change_column :site_items, :author_list, :text
  end
end
