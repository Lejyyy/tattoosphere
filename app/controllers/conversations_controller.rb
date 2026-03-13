class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show ]
  before_action :ensure_participant!, only: [ :show ]

  # GET /conversations
  def index
    @conversations = current_user.conversations
                                 .includes(:messages, :conversation_participants)
                                 .order("messages.created_at DESC")
  end

  # GET /conversations/:id
  def show
    @messages = @conversation.messages.order(:created_at)
    @message  = Message.new

    # Marquer les messages de l'autre participant comme lus
    @messages.where(read_at: nil)
             .where.not(user: current_user)
             .update_all(read_at: Time.current)
  end

  # POST /conversations
  def create
    recipient = find_recipient

    if recipient.nil?
      redirect_to root_path, alert: "Destinataire introuvable." and return
    end

    if recipient == current_user
      redirect_to root_path, alert: "Vous ne pouvez pas vous envoyer un message." and return
    end

    @conversation = Conversation.find_or_create_between(current_user, recipient)
    redirect_to conversation_path(@conversation)
  end

  def mark_read
  @conversation.messages
               .where.not(user: current_user)
               .where(read_at: nil)
               .update_all(read_at: Time.current)
  head :ok
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def ensure_participant!
    unless @conversation.conversation_participants
                        .exists?(participant: current_user)
      redirect_to conversations_path, alert: "Vous n'avez pas accès à cette conversation."
    end
  end

  def find_recipient
    if params[:tatoueur_id]
      Tatoueur.find_by(id: params[:tatoueur_id])
    elsif params[:shop_id]
      Shop.find_by(id: params[:shop_id])
    end
  end
end
