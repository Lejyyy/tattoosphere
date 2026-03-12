class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :tatoueur, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :location
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :is_public

      t.timestamps
    end
  end
end
