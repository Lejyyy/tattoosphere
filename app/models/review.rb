class Review < ApplicationRecord
  belongs_to :user
  belongs_to :tatoueur
  belongs_to :booking
end
