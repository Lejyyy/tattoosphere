class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  belongs_to :tatoueur
end
