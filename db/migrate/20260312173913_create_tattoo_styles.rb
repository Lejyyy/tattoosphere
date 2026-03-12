class CreateTattooStyles < ActiveRecord::Migration[8.1]
  def change
    create_table :tattoo_styles do |t|
      t.string :name

      t.timestamps
    end
  end
end
