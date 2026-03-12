class Medium < ApplicationRecord
  belongs_to :shop
  belongs_to :tatoueur
  belongs_to :portfolio_item
  belongs_to :event
end
