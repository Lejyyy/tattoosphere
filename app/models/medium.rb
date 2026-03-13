class Medium < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  belongs_to :tatoueur,      optional: true
  belongs_to :shop,          optional: true
  belongs_to :event,         optional: true
  belongs_to :portfolio_item, optional: true

  # ================================
  # VALIDATIONS
  # ================================
  MEDIA_TYPES = %w[image video].freeze

  validates :url,        presence: true
  validates :media_type, inclusion: { in: MEDIA_TYPES }, allow_nil: true
  validate  :must_have_owner

  private

  def must_have_owner
    if [ tatoueur, shop, event, portfolio_item ].all?(&:nil?)
      errors.add(:base, "doit appartenir à au moins une ressource")
    end
  end
end
