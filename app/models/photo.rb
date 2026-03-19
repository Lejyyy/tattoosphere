class Photo < ApplicationRecord
  belongs_to :record, polymorphic: true
  belongs_to :tattoo_style, optional: true
  has_one_attached :image

  validates :image, presence: true

  scope :ordered, -> { order(:position) }

  def style_name
    tattoo_style&.name
  end
end
