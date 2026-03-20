class AddReferenceImageUrlToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :reference_image_url, :string
  end
end
