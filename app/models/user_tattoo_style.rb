class UserTattooStyle < ApplicationRecord
  belongs_to :user
  belongs_to :tattoo_style
end
