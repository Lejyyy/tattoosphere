class Tatoueur < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar
  has_many_attached :photos
  has_one_attached :cover
  has_one_attached :identity_document
  has_one_attached :hygiene_certificate
  has_one_attached :identity_selfie
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
  has_many :blocked_slots, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  # ================================
  # VIRTUAL ATTRIBUTES
  # ================================
  attr_accessor :remove_cover
  attr_accessor :remove_avatar

  # ================================
  # SCOPES
  # ================================
  scope :featured, -> { where(featured: true) }
  scope :banned,   -> { where(banned: true) }
  scope :active,   -> { where(is_active: true, banned: false) }

  # ================================
  # VALIDATIONS
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
  # CALLBACKS
  # ================================
  after_save :purge_cover,  if: :remove_cover?
  after_save :purge_avatar, if: :remove_avatar?

  # ================================
  # VÉRIFICATION — HELPERS
  # ================================
  def verification_documents_complete?
    identity_document.attached? &&
      identity_selfie.attached? &&
      hygiene_certificate.attached? &&
      siren.present? &&
      first_name.present? &&
      last_name.present? &&
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

  def verified?               = verified == true
  def pending_verification?   = verification_status == "pending"
  def banned?                 = banned == true
  def featured?               = featured == true

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

  private

  def remove_cover?
    ActiveModel::Type::Boolean.new.cast(remove_cover)
  end

  def purge_cover
    cover.purge
  end

  def remove_avatar?
    ActiveModel::Type::Boolean.new.cast(remove_avatar)
  end

  def purge_avatar
    avatar.purge
  end
end
