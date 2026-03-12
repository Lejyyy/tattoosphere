class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :nickname, :string
    add_column :users, :phone, :string
    add_column :users, :birth_date, :date
    #add_column :users, :role, :string
    add_column :users, :is_active, :boolean
  end
end
