class Tatoueur < ApplicationRecord
   belongs_to :user
  has_one_attached :avatar          # photo de profil
  has_many_attached :photos         # photos supplémentaires

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

  # Validation du format et de la taille de l'avatar
  validates :avatar, content_type: [:png, :jpg, :jpeg, :webp],
                     size: { less_than: 5.megabytes }
end
