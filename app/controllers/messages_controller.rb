class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :ensure_participant!

  # POST /conversations/:conversation_id/messages
  def create
    @message      = @conversation.messages.new(message_params)
    @message.user = current_user
    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      redirect_to conversation_path(@conversation), alert: "Le message ne peut pas être vide."
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
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

  def message_params
    params.require(:message).permit(:content, :attachment)
  end
end
