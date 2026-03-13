class Shop < ApplicationRecord
  belongs_to :user
  has_one_attached :cover            # photo principale du shop
  has_many_attached :photos          # galerie photos du shop

  has_many :conversation_participants, as: :participant
  has_many :conversations, through: :conversation_participants

  has_many :favorites, as: :favoritable

  has_many :shop_tatoueurs
  has_many :tatoueurs, through: :shop_tatoueurs
  has_many :bookings
  has_many :medias
  has_many :socials
  has_many :events

  validates :name, presence: true

  validates :cover, content_type: [ :png, :jpg, :jpeg, :webp ],
                    size: { less_than: 5.megabytes }

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  def coordinates_valid?
    latitude.present? && longitude.present?
  end
end
