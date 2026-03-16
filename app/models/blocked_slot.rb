class BlockedSlot < ApplicationRecord
  belongs_to :tatoueur

  validates :date, :start_time, :end_time, presence: true
  validate  :end_after_start

  private

  def end_after_start
    return unless start_time && end_time
    errors.add(:end_time, "doit être après l'heure de début") if end_time <= start_time
  end
end
