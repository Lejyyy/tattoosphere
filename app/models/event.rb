class Event < ApplicationRecord
  belongs_to :shop, optional: true
  belongs_to :tatoueur, optional: true
  has_one_attached :banner           # bannière de l'événement
  has_many :medias

  validates :name, presence: true
  validate :must_have_owner

  validates :banner, content_type: [:png, :jpg, :jpeg, :webp],
                     size: { less_than: 5.megabytes }

  private

  def must_have_owner
    errors.add(:base, "Un événement doit appartenir à un shop ou un tatoueur") if shop.nil? && tatoueur.nil?
  end
end
