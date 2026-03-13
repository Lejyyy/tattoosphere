class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])
    stream_from "conversation_#{conversation.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
