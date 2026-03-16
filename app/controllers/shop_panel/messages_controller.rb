class ShopPanel::MessagesController < ShopPanel::BaseController
  def index
    shop = current_user.shop
    return redirect_to root_path, alert: "Profil shop introuvable." unless shop

    conv_ids = ConversationParticipant
      .where(participant_type: "Shop", participant_id: shop.id)
      .pluck(:conversation_id)

    @conversations = Conversation
      .where(id: conv_ids)
      .preload(:messages, conversation_participants: :participant)
      .order(updated_at: :desc)
  end
end
