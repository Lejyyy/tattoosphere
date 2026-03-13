class AddCoordinatesToTatoueurs < ActiveRecord::Migration[8.1]
  def change
    add_column :tatoueurs, :latitude, :float
    add_column :tatoueurs, :longitude, :float
  end
end
