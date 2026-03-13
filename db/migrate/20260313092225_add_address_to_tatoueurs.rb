class AddAddressToTatoueurs < ActiveRecord::Migration[8.1]
  def change
    add_column :tatoueurs, :address, :string
  end
end
