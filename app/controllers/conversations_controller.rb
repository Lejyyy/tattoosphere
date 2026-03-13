class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Toutes les conversations de l'utilisateur connecté
    @conversations = current_user.conversations
                                 .includes(:messages, :conversation_participants)
                                 .order("messages.created_at DESC")
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages.order(:created_at)
    @message = Message.new

    # Marquer les messages comme lus
    @messages.where(read_at: nil).where.not(user: current_user).update_all(read_at: Time.current)
  end

  def create
    # Trouver le destinataire selon son type
    recipient = find_recipient

    @conversation = Conversation.find_or_create_between(current_user, recipient)
    redirect_to conversation_path(@conversation)
  end

  private

  def find_recipient
    if params[:tatoueur_id]
      Tatoueur.find(params[:tatoueur_id])
    elsif params[:shop_id]
      Shop.find(params[:shop_id])
    end
  end
end
