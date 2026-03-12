class CreateShops < ActiveRecord::Migration[8.1]
  def change
    create_table :shops do |t|
      t.string :name
      t.string :email
      t.string :address
      t.string :phone
      t.text :description
      t.string :open_hours
      t.boolean :is_active

      t.timestamps
    end
  end
end
