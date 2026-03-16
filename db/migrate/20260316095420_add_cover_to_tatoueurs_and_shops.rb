class AddCoverToTatoueursAndShops < ActiveRecord::Migration[8.1]
  def change
  add_column :tatoueurs, :cover_color, :string
  add_column :shops,     :cover_color, :string
  end
end
