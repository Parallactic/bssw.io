# frozen_string_literal: true

class AddAuthorListToSiteItems < ActiveRecord::Migration[5.0]
  def change
    add_column :site_items, :author_list, :string
  end
end
