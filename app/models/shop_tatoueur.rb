class ShopTatoueur < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  belongs_to :shop
  belongs_to :tatoueur

  # ================================
  # VALIDATIONS
  # ================================
  validates :tatoueur_id, uniqueness: { scope: :shop_id, message: "est déjà associé à ce shop" }
  validate  :end_after_start

  # ================================
  # SCOPES
  # ================================
  scope :active,   -> { where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", Date.today, Date.today) }
  scope :inactive, -> { where("end_date < ?", Date.today) }

  # ================================
  # HELPERS
  # ================================
  def active?
    start_date <= Date.today && (end_date.nil? || end_date >= Date.today)
  end

  private

  def end_after_start
    return unless start_date && end_date
    errors.add(:end_date, "doit être après la date de début") if end_date <= start_date
  end
end
