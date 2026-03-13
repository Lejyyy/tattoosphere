class Tatoueur < ApplicationRecord
   belongs_to :user
  has_one_attached :avatar          # photo de profil
  has_many_attached :photos         # photos supplémentaires

  has_many :conversation_participants, as: :participant
  has_many :conversations, through: :conversation_participants

  has_many :favorites, as: :favoritable  # si Favorite est polymorphique
  has_many :portfolio_items, through: :portfolios

  has_many :tatoueur_styles
  has_many :tattoo_styles, through: :tatoueur_styles
  has_many :shop_tatoueurs
  has_many :shops, through: :shop_tatoueurs
  has_many :bookings
  has_many :reviews
  has_many :availabilities
  has_many :portfolios
  has_many :medias
  has_many :socials
  has_many :events

  validates :nickname, :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  validates :deposit_amount, numericality: { greater_than: 0 }, allow_nil: true

  # Validation du format et de la taille de l'avatar
  validates :avatar, content_type: [ :png, :jpg, :jpeg, :webp ],
                     size: { less_than: 5.megabytes }

   geocoded_by :geocodable_address
  after_validation :geocode, if: :address_changed?

  def geocodable_address
    address.present? ? address : shops.first&.address
  end

  def coordinates_valid?
    latitude.present? && longitude.present?
  end

# Validation IBAN basique
validates :iban, format: {
  with: /\A[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}\z/,
  message: "n'est pas un IBAN valide"
}, allow_blank: true

def bank_details_complete?
  iban.present? && bic.present?
end

# Masquer l'IBAN pour l'affichage (ex: FR76 **** **** **** 1234)
def masked_iban
  return nil unless iban.present?
  iban.gsub(/.(?=.{4})/, "*")
end
end
