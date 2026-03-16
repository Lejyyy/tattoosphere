class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_participant
  before_action :set_conversation,    only: [ :show, :mark_read, :bubble, :destroy ]
  before_action :ensure_participant!, only: [ :show, :mark_read, :bubble, :destroy ]

  def index
    conversation_ids = ConversationParticipant
      .where(participant_type: @current_participant.class.name,
             participant_id:   @current_participant.id)
      .pluck(:conversation_id)

    @conversations = Conversation
      .where(id: conversation_ids)
      .preload(:messages, conversation_participants: :participant)
      .order(updated_at: :desc)
  end

  def show
    @current_participant = resolve_participant_for(@conversation)
    @messages = @conversation.messages.includes(:user).order(:created_at)
    @message  = Message.new
    @conversation.messages
                 .where(read_at: nil)
                 .where.not(user: current_user)
                 .update_all(read_at: Time.current)
  end

  def create
    recipient = find_recipient
    if recipient.nil?
      redirect_to root_path, alert: "Destinataire introuvable." and return
    end
    if recipient == @current_participant
      redirect_to root_path, alert: "Vous ne pouvez pas vous envoyer un message." and return
    end
    @conversation = Conversation.find_or_create_between(@current_participant, recipient)
    redirect_to conversation_path(@conversation)
  end

  def destroy
    @conversation.destroy
    respond_to do |format|
      format.html { redirect_to conversations_path, notice: "Conversation supprimée." }
      format.json { head :no_content }
    end
  end

  def mark_read
    @conversation.messages
                 .where.not(user: current_user)
                 .where(read_at: nil)
                 .update_all(read_at: Time.current)
    head :ok
  end

  def bubble
    @current_participant = resolve_participant_for(@conversation)
    @messages = @conversation.messages.includes(:user).order(:created_at).last(30)
    @other    = @conversation.other_participant(@current_participant)
    render layout: false
  end

  def search_recipients
    q = params[:q].to_s.strip.downcase
    results = []

    if q.length >= 2
      users = User.where("LOWER(nickname) LIKE ?", "%#{q}%")
                  .where.not(id: current_user.id)
                  .limit(5)
                  .map { |u| { id: u.id, type: "User", name: u.nickname, subtitle: "Membre", avatar: u.avatar.attached? ? url_for(u.avatar) : nil } }

      tatoueurs = Tatoueur.where("LOWER(nickname) LIKE ?", "%#{q}%")
                          .where.not(id: current_user.tatoueur&.id)
                          .limit(5)
                          .map { |t| { id: t.id, type: "Tatoueur", name: t.nickname, subtitle: "Tatoueur", avatar: t.avatar.attached? ? url_for(t.avatar) : nil } }

      shops = Shop.where("LOWER(name) LIKE ?", "%#{q}%")
                  .where.not(id: current_user.shop&.id)
                  .limit(5)
                  .map { |s| { id: s.id, type: "Shop", name: s.name, subtitle: "Shop", avatar: s.avatar.attached? ? url_for(s.avatar) : nil } }

      results = users + tatoueurs + shops
    end

    render json: results
  end

  private

  def set_current_participant
    @current_participant = current_user.tatoueur || current_user.shop || current_user
  end

  def resolve_participant_for(conversation)
    [ current_user.tatoueur, current_user.shop, current_user ].compact.find do |p|
      conversation.conversation_participants
                  .exists?(participant_type: p.class.name, participant_id: p.id)
    end || @current_participant
  end

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def ensure_participant!
    candidates = [ current_user, current_user.tatoueur, current_user.shop ].compact
    authorized = candidates.any? do |p|
      @conversation.conversation_participants
                   .exists?(participant_type: p.class.name, participant_id: p.id)
    end
    unless authorized
      redirect_to conversations_path, alert: "Vous n'avez pas accès à cette conversation."
    end
  end

  def find_recipient
    if params[:tatoueur_id]
      Tatoueur.find_by(id: params[:tatoueur_id])
    elsif params[:shop_id]
      Shop.find_by(id: params[:shop_id])
    elsif params[:user_id]
      User.find_by(id: params[:user_id])
    end
  end
end
