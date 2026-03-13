class Portfolio < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  belongs_to :tatoueur
  has_many   :portfolio_items, dependent: :destroy
  has_many   :favorites, as: :favoritable, dependent: :destroy

  # ================================
  # VALIDATIONS
  # ================================
  validates :name, presence: true
end
