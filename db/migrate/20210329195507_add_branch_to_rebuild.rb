class AddBranchToRebuild < ActiveRecord::Migration[6.0]
  def change
    add_column :rebuilds, :content_branch, :string
    add_column :rebuild_statuses, :code_branch, :string
  end
end
