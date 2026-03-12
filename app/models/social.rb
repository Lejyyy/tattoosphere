# app/models/social.rb
class Social < ApplicationRecord
  belongs_to :shop, optional: true
  belongs_to :tatoueur, optional: true

  validates :platform, :url, presence: true
end