class Review < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  belongs_to :user
  belongs_to :booking
  belongs_to :tatoueur

  # ================================
  # VALIDATIONS
  # ================================
  validates :rating, presence: true,
                     numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, presence: true
  validates :booking_id, uniqueness: true  # un booking = une seule review
end
