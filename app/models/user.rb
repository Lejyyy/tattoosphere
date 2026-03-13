class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ================================
  # ASSOCIATIONS
  # ================================
  has_one  :tatoueur
  has_one  :shop
  has_many :bookings
  has_many :reviews
  has_many :messages
  has_many :conversation_participants, as: :participant, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :favorites, dependent: :destroy
  has_many :favorite_tatoueurs,       through: :favorites, source: :favoritable, source_type: "Tatoueur"
  has_many :favorite_shops,           through: :favorites, source: :favoritable, source_type: "Shop"
  has_many :favorite_portfolios,      through: :favorites, source: :favoritable, source_type: "Portfolio"
  has_many :favorite_portfolio_items, through: :favorites, source: :favoritable, source_type: "PortfolioItem"

  # ================================
  # VALIDATIONS
  # ================================
  ROLES = %w[user tatoueur shop_owner admin].freeze
  validates :first_name, :last_name, :nickname, presence: true
  validates :nickname, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: ROLES }
  validate  :role_assignment_allowed

  # ================================
  # HELPERS
  # ================================
  def tatoueur?
    role == "tatoueur"
  end

  def shop_owner?
    role == "shop_owner"
  end

  def user?
    role == "user"
  end

  def admin?
    role == "admin"
  end

  def favorited?(resource)
    favorites.exists?(favoritable: resource)
  end

  private

  def role_assignment_allowed
    errors.add(:role, "ne peut pas être attribué de cette façon") if role_changed? && role == "admin"
  end
end
