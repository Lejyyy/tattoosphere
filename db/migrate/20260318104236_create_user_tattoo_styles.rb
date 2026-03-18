class CreateUserTattooStyles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_tattoo_styles do |t|
      t.references :user,         null: false, foreign_key: true
      t.references :tattoo_style, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_tattoo_styles, [ :user_id, :tattoo_style_id ], unique: true
  end
end
