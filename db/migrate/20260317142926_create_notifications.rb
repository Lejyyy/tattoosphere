class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user,       null: false, foreign_key: true
      t.string     :kind,       null: false   # "message", "booking_confirmed", "booking_cancelled", "new_event"
      t.string     :title,      null: false
      t.text       :body
      t.string     :url                        # lien vers la ressource concernée
      t.boolean    :read,       default: false, null: false
      t.references :notifiable, polymorphic: true, null: true  # Message, Booking, Event

      t.timestamps
    end

    add_index :notifications, [ :user_id, :read ]
  end
end
