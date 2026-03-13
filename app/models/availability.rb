class Availability < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  belongs_to :tatoueur

  # ================================
  # VALIDATIONS
  # ================================
  DAYS = (0..6).freeze  # 0 = dimanche, 6 = samedi (convention Ruby/JS)

  validates :day_of_week, presence: true,
                          inclusion: { in: DAYS, message: "doit être compris entre 0 (dimanche) et 6 (samedi)" }
  validates :start_time,  presence: true
  validates :end_time,    presence: true
  validate  :end_after_start
  validate  :no_overlap

  private

  def end_after_start
    return unless start_time && end_time
    errors.add(:end_time, "doit être après l'heure de début") if end_time <= start_time
  end

  def no_overlap
    return unless tatoueur && day_of_week && start_time && end_time

    overlapping = tatoueur.availabilities
                          .where(day_of_week: day_of_week)
                          .where.not(id: id)
                          .where("start_time < ? AND end_time > ?", end_time, start_time)

    errors.add(:base, "chevauche une disponibilité existante") if overlapping.exists?
  end
end
