class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  has_one_attached :attachment

  validates :content, presence: true, unless: :attachment?
  validates :attachment, content_type: [ :png, :jpg, :jpeg, :pdf ],
                       size: { less_than: 5.megabytes },
                       if: :attachment?

  after_create_commit :broadcast_message

  private

  def attachment?
    attachment.attached?
  end

  def broadcast_message
    ActionCable.server.broadcast(
      "conversation_#{conversation_id}",
      {
        message:         content,
        sender:          user&.nickname || user&.first_name,
        created_at:      created_at.strftime("%H:%M"),
        message_id:      id,
        attachment_url:  attachment.attached? ? Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true) : nil,
        attachment_name: attachment.attached? ? attachment.filename.to_s : nil
      }
    )
  end
end
