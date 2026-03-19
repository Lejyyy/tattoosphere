class Shop < ApplicationRecord
  belongs_to :user
  has_one_attached :cover
  has_many_attached :photos
  has_one_attached :avatar
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :conversation_participants, as: :participant
  has_many :conversations, through: :conversation_participants
  has_many :favorites, as: :favoritable
  has_many :shop_tatoueurs
  has_many :tatoueurs, through: :shop_tatoueurs
  has_many :bookings
  has_many :medias
  has_many :socials
  has_many :events
  has_many :gallery_photos, class_name: "Photo", as: :record, dependent: :destroy

  # ================================
  # SCOPES
  # ================================
  scope :featured, -> { where(featured: true) }
  scope :banned,   -> { where(banned: true) }
  scope :active,   -> { where(is_active: true, banned: false) }

  # ================================
  # VALIDATIONS
  # ================================
  validates :name, presence: true
  validates :cover, content_type: [ :png, :jpg, :jpeg, :webp ],
                    size: { less_than: 5.megabytes }

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  # ================================
  # HELPERS
  # ================================
  def coordinates_valid?
    latitude.present? && longitude.present?
  end

  def banned?   = banned == true
  def featured? = featured == true
end
