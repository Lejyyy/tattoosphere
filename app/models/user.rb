class User < ApplicationRecord
 devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookings
  has_many :reviews
  has_one :tatoueur   # si le user est tatoueur
  has_one :shop       # si le user est shop owner
  has_many :messages
  has_many :conversation_participants, as: :participant
  has_many :conversations, through: :conversation_participants
  has_many :favorites

  ROLES = %w[user tatoueur shop_owner].freeze

  validates :role, inclusion: { in: ROLES }
  validates :first_name, :last_name, presence: true

   def tatoueur?
    role == "tatoueur"
  end

  def shop_owner?
    role == "shop_owner"
  end

  def user?
    role == "user"
  end
end
