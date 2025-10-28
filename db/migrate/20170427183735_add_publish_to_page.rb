# frozen_string_literal: true

class AddPublishToPage < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :publish, :boolean
  end
end
