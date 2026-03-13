class AddPaymentFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :deposit_amount, :decimal
    add_column :bookings, :deposit_paid, :boolean
    add_column :bookings, :deposit_paid_at, :datetime
    add_column :bookings, :paypal_order_id, :string
    add_column :bookings, :paypal_payment_id, :string
    add_column :bookings, :cancelled_at, :datetime
    add_column :bookings, :cancellation_reason, :text
  end
end
