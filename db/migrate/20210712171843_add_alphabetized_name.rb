class AddAlphabetizedName < ActiveRecord::Migration[6.0]
  def change
    add_column :authors, :alphabetized_name, :string
  end
end
