class PortfolioItem < ApplicationRecord
  belongs_to :portfolio
  has_many_attached :images          # plusieurs images par réalisation
  has_many :portfolio_styles
  has_many :tattoo_styles, through: :portfolio_styles
  has_many :medias

  has_many :favorites, as: :favoritable  # cohérent avec tes routes
  has_one :tatoueur, through: :portfolio  # accès rapide au tatoueur

  validates :portfolio, presence: true

  validates :images, content_type: [ :png, :jpg, :jpeg, :webp ],
                     size: { less_than: 10.megabytes }
end
