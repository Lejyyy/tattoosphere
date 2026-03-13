class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :ensure_participant!

  # POST /conversations/:conversation_id/messages
  def create
    @message      = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      # Le broadcast est géré dans le modèle via after_create_commit
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
    unless @conversation.conversation_participants
                        .exists?(participant: current_user)
      redirect_to conversations_path, alert: "Vous n'avez pas accès à cette conversation."
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
