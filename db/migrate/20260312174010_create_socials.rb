class CreateSocials < ActiveRecord::Migration[8.1]
  def change
    create_table :socials do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :tatoueur, null: false, foreign_key: true
      t.string :platform
      t.string :url

      t.timestamps
    end
  end
end
