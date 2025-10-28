class AddDisplayNameToContribution < ActiveRecord::Migration[7.0]
  def change
    add_column :contributions, :display_name, :string
  end
end
