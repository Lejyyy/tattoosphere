class ConversationPolicy < ApplicationPolicy
  def index?  = true
  def show?   = participant?
  def create? = user.present?

  private

  def participant?
    record.conversation_participants
          .exists?(participant_type: user.class.name, participant_id: user.id)
  end
end
