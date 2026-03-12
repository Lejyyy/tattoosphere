class CreateTatoueurs < ActiveRecord::Migration[8.1]
  def change
    create_table :tatoueurs do |t|
      t.string :nickname
      t.string :first_name
      t.string :last_name
      t.string :email
      t.text :description
      t.boolean :is_active

      t.timestamps
    end
  end
end
