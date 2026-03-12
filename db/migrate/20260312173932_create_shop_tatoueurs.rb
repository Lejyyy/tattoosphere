class CreateShopTatoueurs < ActiveRecord::Migration[8.1]
  def change
    create_table :shop_tatoueurs do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :tatoueur, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
