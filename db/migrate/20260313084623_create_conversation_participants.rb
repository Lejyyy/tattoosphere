class CreateConversationParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :participant_type
      t.integer :participant_id

      t.timestamps
    end
  end
end
