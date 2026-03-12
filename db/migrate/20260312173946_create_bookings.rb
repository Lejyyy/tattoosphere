class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true
      t.references :tatoueur, null: false, foreign_key: true
      t.date :date
      t.string :status
      t.text :description
      t.decimal :price_estimated
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
