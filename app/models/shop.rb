class Shop < ApplicationRecord
  belongs_to :user
  has_one_attached :cover            # photo principale du shop
  has_many_attached :photos          # galerie photos du shop

  has_many :shop_tatoueurs
  has_many :tatoueurs, through: :shop_tatoueurs
  has_many :bookings
  has_many :medias
  has_many :socials
  has_many :events

  validates :name, presence: true

  validates :cover, content_type: [:png, :jpg, :jpeg, :webp],
                    size: { less_than: 5.megabytes }
end
