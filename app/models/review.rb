class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :user
  belongs_to :tatoueur

  validates :rating,  presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :comment,    length: { minimum: 10, maximum: 1000 }
  validates :booking_id, uniqueness: { message: "a déjà un avis" }
  validate  :booking_must_be_confirmed
  validate  :user_must_own_booking

  scope :recent, -> { order(created_at: :desc) }

  def replied?
    reply.present?
  end

  private

  def booking_must_be_confirmed
    return unless booking
    unless %w[confirmed done].include?(booking.status)
      errors.add(:base, "Vous ne pouvez laisser un avis que pour une réservation confirmée.")
    end
  end

  def user_must_own_booking
    return unless booking && user
    unless booking.user_id == user.id
      errors.add(:base, "Vous ne pouvez pas laisser un avis pour cette réservation.")
    end
  end
end
