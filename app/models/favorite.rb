# app/models/favorite.rb
class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  validates :user_id, uniqueness: { scope: [ :favoritable_type, :favoritable_id ] }
end

# app/models/user.rb — ajouter
has_many :favorites, dependent: :destroy
has_many :favorite_tatoueurs,    through: :favorites, source: :favoritable, source_type: "Tatoueur"
has_many :favorite_shops,        through: :favorites, source: :favoritable, source_type: "Shop"
has_many :favorite_portfolios,   through: :favorites, source: :favoritable, source_type: "Portfolio"
has_many :favorite_portfolio_items, through: :favorites, source: :favoritable, source_type: "PortfolioItem"

# Helper pour savoir si un élément est en favori
def favorited?(resource)
  favorites.exists?(favoritable: resource)
end

# app/models/tatoueur.rb — ajouter
has_many :favorites, as: :favoritable, dependent: :destroy

# app/models/shop.rb — ajouter
has_many :favorites, as: :favoritable, dependent: :destroy

# app/models/portfolio.rb — ajouter
has_many :favorites, as: :favoritable, dependent: :destroy

# app/models/portfolio_item.rb — ajouter
has_many :favorites, as: :favoritable, dependent: :destroy
