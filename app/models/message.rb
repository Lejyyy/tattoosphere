class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true

  after_create_commit :broadcast_message

  private

  def broadcast_message
    ActionCable.server.broadcast(
      "conversation_#{conversation_id}",
      {
        message:    content,
        sender:     user&.nickname || user&.first_name,
        created_at: created_at.strftime("%H:%M"),
        message_id: id
      }
    )
  end
end
