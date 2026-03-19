class ContactRequest < ApplicationRecord
  SUBJECTS = [
    "Question générale",
    "Problème technique",
    "Signaler un contenu",
    "Partenariat",
    "Autre"
  ].freeze

  STATUSES = %w[pending read answered].freeze

  validates :name,    presence: true, length: { maximum: 100 }
  validates :email,   presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, inclusion: { in: SUBJECTS }
  validates :message, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :status,  inclusion: { in: STATUSES }

  scope :pending,  -> { where(status: "pending") }
  scope :recent,   -> { order(created_at: :desc) }

  def pending?  = status == "pending"
  def read?     = status == "read"
  def answered? = status == "answered"
end
