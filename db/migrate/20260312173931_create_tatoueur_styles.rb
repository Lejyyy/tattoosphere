class CreateTatoueurStyles < ActiveRecord::Migration[8.1]
  def change
    create_table :tatoueur_styles do |t|
      t.references :tatoueur, null: false, foreign_key: true
      t.references :tattoo_style, null: false, foreign_key: true

      t.timestamps
    end
  end
end
