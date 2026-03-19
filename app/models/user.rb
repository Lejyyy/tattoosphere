class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ================================
  # ASSOCIATIONS
  # ================================
  has_one  :tatoueur
  has_one  :shop
  has_one :subscription, dependent: :destroy
  has_one :onboarding_funnel, dependent: :destroy
  has_one_attached :avatar

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

  has_many :event_participations, dependent: :destroy
  has_many :participated_events, through: :event_participations, source: :event
  has_many :reports, foreign_key: :reporter_id, dependent: :destroy
  has_many :admin_logs, foreign_key: :admin_user_id
  has_many :notifications, dependent: :destroy
  has_many :user_tattoo_styles, dependent: :destroy
  has_many :preferred_styles, through: :user_tattoo_styles, source: :tattoo_style
  has_many :reviews

  attr_writer :preferred_style_ids
  after_create :save_preferred_styles

  # ================================
  # SCOPES
  # ================================
  scope :banned,  -> { where(banned: true) }
  scope :active,  -> { where(banned: false) }

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
  def tatoueur?   = role == "tatoueur"
  def shop_owner? = role == "shop_owner"
  def user?       = role == "user"
  def admin?      = role == "admin"
  def banned?     = banned == true
  def active?     = !banned?
  def subscribed?
  subscription&.active?
  end
  def pro_form_completed?
  onboarding_funnel&.step.in?(%w[form_completed subscription_page_visited plan_selected subscribed])
  end

def can_access_subscription_page?
  pro_form_completed? || subscribed?
end

def subscription_plan
  subscription&.plan
end

def can_create_event_free?
  # Premier event toujours gratuit
  return true if events.count.zero?
  # Events gratuits inclus dans le plan
  subscription&.free_events_remaining.to_i > 0
end

def favorited?(resource)
  favorites.exists?(favoritable: resource)
end



  private

  def role_assignment_allowed
    errors.add(:role, "ne peut pas être attribué de cette façon") if role_changed? && role == "admin"
  end

  def save_preferred_styles
  return unless @preferred_style_ids.present?
  @preferred_style_ids.reject(&:blank?).each do |id|
    user_tattoo_styles.find_or_create_by!(tattoo_style_id: id)
  end
end
end
