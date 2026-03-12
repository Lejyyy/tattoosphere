class AddUserRefToTatoueur < ActiveRecord::Migration[8.1]
  def change
    add_reference :tatoueurs, :user, null: false, foreign_key: true
  end
end
