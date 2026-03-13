class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :participant, polymorphic: true
  # participant peut être : User, Tatoueur, ou Shop
end
