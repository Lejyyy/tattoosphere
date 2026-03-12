class CreateMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :media do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :tatoueur, null: false, foreign_key: true
      t.references :portfolio_item, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :url
      t.string :media_type

      t.timestamps
    end
  end
end
