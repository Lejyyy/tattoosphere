class Event < ApplicationRecord
  belongs_to :shop,     optional: true
  belongs_to :tatoueur, optional: true
  has_one_attached :banner
  has_many :medias
  has_many :event_participations, dependent: :destroy
  has_many :participants, through: :event_participations, source: :user
  has_many :reports, as: :reportable, dependent: :destroy

  # ================================
  # SCOPES
  # ================================
  scope :featured, -> { where(featured: true) }
  scope :upcoming, -> { where("start_date >= ?", Time.current).order(start_date: :asc) }

  # ================================
  # VALIDATIONS
  # ================================
  validates :name, presence: true
  validates :start_date, :end_date, presence: true
  validate  :must_have_owner
  validate  :end_after_start
  validates :banner, content_type: [ :png, :jpg, :jpeg, :webp ],
                     size: { less_than: 5.megabytes }

  # ================================
  # HELPERS
  # ================================
  def featured? = featured == true

  after_create_commit :notify_followers

  private

  def must_have_owner
    errors.add(:base, "Un événement doit appartenir à un shop ou un tatoueur") if shop.nil? && tatoueur.nil?
  end

  def end_after_start
    return unless start_date && end_date
    errors.add(:end_date, "doit être après la date de début") if end_date <= start_date
  end

  def notify_followers
    NotificationService.new_event(self)
  end
end
