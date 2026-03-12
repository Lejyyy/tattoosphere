class CreatePortfolios < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolios do |t|
      t.references :tatoueur, null: false, foreign_key: true
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
