class AddMissingFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :payment_method, :string
    add_column :bookings, :deposit_confirmed_at, :datetime
  end
end
