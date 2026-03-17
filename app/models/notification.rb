class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  KINDS = %w[message booking_confirmed booking_cancelled new_event].freeze

  validates :kind,  inclusion: { in: KINDS }
  validates :title, presence: true

  scope :unread,   -> { where(read: false) }
  scope :recent,   -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read: true) unless read?
  end
end
