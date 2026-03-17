class AddSharedProfileToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :shared_profile_type, :string
    add_column :messages, :shared_profile_id, :integer
  end
end
