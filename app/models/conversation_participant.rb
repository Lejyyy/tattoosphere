class ConversationParticipant < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  belongs_to :conversation
  belongs_to :participant, polymorphic: true

  # ================================
  # VALIDATIONS
  # ================================
  validates :participant_id, uniqueness: {
    scope: [ :conversation_id, :participant_type ],
    message: "participe déjà à cette conversation"
  }
end
