class AddCoverColorToTatoueurs < ActiveRecord::Migration[8.1]
  def change
    add_column :tatoueurs, :cover_color, :string unless column_exists?(:tatoueurs, :cover_color)
  end
end
