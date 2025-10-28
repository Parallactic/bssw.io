class AddCodeBranchAndCommitHashToRebuilds < ActiveRecord::Migration[6.0]
  def change
    add_column :rebuilds, :commit_hash, :string
  end
end
