class AdminLog < ApplicationRecord
  belongs_to :admin_user, class_name: "User"

  scope :recent, -> { order(created_at: :desc) }
end
