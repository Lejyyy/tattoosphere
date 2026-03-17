class AddCoverColorToShops < ActiveRecord::Migration[8.1]
  def change
    add_column :shops, :cover_color, :string unless column_exists?(:shops, :cover_color)
  end
end
