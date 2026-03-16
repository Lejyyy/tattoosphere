class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy

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

  def self.find_or_create_between(participant_a, participant_b)
    between(participant_a, participant_b) || create_between(participant_a, participant_b)
  end

  def self.create_between(participant_a, participant_b)
    conversation = create!
    conversation.conversation_participants.create!(participant: participant_a)
    conversation.conversation_participants.create!(participant: participant_b)
    conversation
  end

  # Accepte maintenant un participant polymorphique (Tatoueur, Shop, ou User)
  def other_participant(current_participant)
    conversation_participants
      .where.not(
        participant_type: current_participant.class.name,
        participant_id:   current_participant.id
      )
      .first
      &.participant
  end

  def unread_count_for(user)
    messages.where.not(user: user).where(read_at: nil).count
  end

  def last_message
    messages.order(:created_at).last
  end

  # Nom d'affichage d'un participant quel que soit son type
  def self.participant_name(participant)
    return "Inconnu" unless participant
    participant.try(:nickname) ||
      participant.try(:name) ||
      "#{participant.try(:first_name)} #{participant.try(:last_name)}".strip.presence ||
      "Inconnu"
  end
end
