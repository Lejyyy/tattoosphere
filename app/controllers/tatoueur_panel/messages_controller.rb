class TatoueurPanel::MessagesController < TatoueurPanel::BaseController
  def index
    tatoueur = current_user.tatoueur
    return redirect_to root_path, alert: "Profil tatoueur introuvable." unless tatoueur

    conv_ids = ConversationParticipant
      .where(participant_type: "Tatoueur", participant_id: tatoueur.id)
      .pluck(:conversation_id)

    @conversations = Conversation
      .where(id: conv_ids)
      .preload(:messages, conversation_participants: :participant)
      .order(updated_at: :desc)
  end
end
