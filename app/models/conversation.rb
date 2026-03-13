class Conversation < ApplicationRecord
  # ================================
  # ASSOCIATIONS
  # ================================
  has_many :messages,                dependent: :destroy
  has_many :conversation_participants, dependent: :destroy

  # ================================
  # CLASS METHODS
  # ================================

  # Retrouve une conversation existante entre deux participants
  def self.between(participant_a, participant_b)
    joins(:conversation_participants)
      .where(conversation_participants: {
        participant_type: participant_a.class.name,
        participant_id:   participant_a.id
      })
      .where(id: joins(:conversation_participants).where(
        conversation_participants: {
          participant_type: participant_b.class.name,
          participant_id:   participant_b.id
        }
      ))
      .first
  end

  # Retrouve ou crée une conversation entre deux participants
  def self.find_or_create_between(participant_a, participant_b)
    between(participant_a, participant_b) || create_between(participant_a, participant_b)
  end

  # Crée une nouvelle conversation entre deux participants
  def self.create_between(participant_a, participant_b)
    conversation = create!
    conversation.conversation_participants.create!(participant: participant_a)
    conversation.conversation_participants.create!(participant: participant_b)
    conversation
  end

  # ================================
  # INSTANCE METHODS
  # ================================

  # Retourne l'autre participant dans la conversation
  def other_participant(current_participant)
    conversation_participants
      .where.not(
        participant_type: current_participant.class.name,
        participant_id:   current_participant.id
      )
      .first&.participant
  end

  # Compte les messages non lus pour un user donné
  # (messages envoyés par l'autre participant, sans read_at)
  def unread_count_for(user)
    messages.where.not(user: user).where(read_at: nil).count
  end
end
