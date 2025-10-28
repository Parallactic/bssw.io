# frozen_string_literal: true

class CreateGithubImports < ActiveRecord::Migration[5.0]
  def change
    create_table :github_imports, &:timestamps
  end
end
