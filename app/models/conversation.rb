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

  def other_participant(current_user)
    conversation_participants
      .where.not(participant_type: current_user.class.name, participant_id: current_user.id)
      .first
      &.participant
  end

  def unread_count_for(user)
    messages.where.not(user: user).where(read_at: nil).count
  end
end
