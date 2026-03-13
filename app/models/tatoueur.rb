class Tatoueur < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar
  has_many_attached :photos

  # Documents de vérification
  has_one_attached :identity_document      # pièce d'identité
  has_one_attached :hygiene_certificate    # certification hygiène & sécurité

  has_many :conversation_participants, as: :participant, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :tatoueur_styles
  has_many :tattoo_styles, through: :tatoueur_styles
  has_many :shop_tatoueurs
  has_many :shops, through: :shop_tatoueurs
  has_many :bookings
  has_many :reviews
  has_many :availabilities
  has_many :portfolios
  has_many :portfolio_items, through: :portfolios
  has_many :medias
  has_many :socials
  has_many :events
  has_many :favorites, as: :favoritable, dependent: :destroy

  # ================================
  # VÉRIFICATION
  # ================================
  VERIFICATION_STATUSES = %w[unsubmitted pending approved rejected].freeze

  validates :verification_status, inclusion: { in: VERIFICATION_STATUSES }
  validates :siren, format: { with: /\A\d{9}\z/, message: "doit contenir exactement 9 chiffres" }, allow_blank: true

  validates :nickname, :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true
  validates :deposit_amount, numericality: { greater_than: 0 }, allow_nil: true
  validates :avatar, content_type: [ :png, :jpg, :jpeg, :webp ],
                     size: { less_than: 5.megabytes }
  validates :iban, format: {
    with: /\A[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}\z/,
    message: "n'est pas un IBAN valide"
  }, allow_blank: true

  geocoded_by :geocodable_address
  after_validation :geocode, if: :address_changed?

  # ================================
  # VÉRIFICATION — HELPERS
  # ================================
  def verification_documents_complete?
    identity_document.attached? &&
      hygiene_certificate.attached? &&
      siren.present? &&
      bank_details_complete?
  end

  def submit_for_verification!
    return false unless verification_documents_complete?
    update!(
      verification_status: "pending",
      verification_submitted_at: Time.current
    )
  end

  def approve_verification!
    update!(
      verified: true,
      verification_status: "approved",
      verification_reviewed_at: Time.current,
      verification_rejected_reason: nil
    )
  end

  def reject_verification!(reason)
    update!(
      verified: false,
      verification_status: "rejected",
      verification_reviewed_at: Time.current,
      verification_rejected_reason: reason
    )
  end

  def verified?
    verified == true
  end

  def pending_verification?
    verification_status == "pending"
  end

  # ================================
  # AUTRES HELPERS
  # ================================
  def geocodable_address
    address.present? ? address : shops.first&.address
  end

  def coordinates_valid?
    latitude.present? && longitude.present?
  end

  def bank_details_complete?
    iban.present? && bic.present?
  end

  def masked_iban
    return nil unless iban.present?
    iban.gsub(/.(?=.{4})/, "*")
  end
end
