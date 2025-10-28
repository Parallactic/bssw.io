# frozen_string_literal: true

class AddPathsToWhatIsAndHowTos < ActiveRecord::Migration[5.0]
  def change
    add_column :what_is, :path, :string
    add_column :how_tos, :path, :string
  end
end
