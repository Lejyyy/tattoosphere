class Social < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  belongs_to :shop,     optional: true
  belongs_to :tatoueur, optional: true

  # ================================
  # VALIDATIONS
  # ================================
  PLATFORMS = %w[instagram facebook tiktok twitter youtube pinterest].freeze

  validates :platform, presence: true, inclusion: { in: PLATFORMS }
  validates :url,      presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "n'est pas une URL valide" }
  validate  :must_have_owner

  private

  def must_have_owner
    errors.add(:base, "doit appartenir à un shop ou un tatoueur") if shop.nil? && tatoueur.nil?
  end
end
