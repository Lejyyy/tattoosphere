class CreateBlockedSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :blocked_slots do |t|
      t.timestamps
    end
  end
end
