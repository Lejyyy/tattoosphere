class AddUserRefToShop < ActiveRecord::Migration[8.1]
  def change
    add_reference :shops, :user, null: false, foreign_key: true
  end
end
