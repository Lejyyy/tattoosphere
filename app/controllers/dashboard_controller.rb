class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # Bookings récents
    @bookings = current_user.bookings
                            .includes(:tatoueur, :shop)
                            .order(date: :desc)
                            .limit(5)

    # Conversations non lues
    @conversations = current_user.conversations
                                 .includes(:messages, :conversation_participants)
                                 .order("messages.created_at DESC")
                                 .limit(5)

    @unread_count = @conversations.sum { |c| c.unread_count_for(current_user) }

    # Profil tatoueur ou shop si existant
    @tatoueur = current_user.tatoueur
    @shop     = current_user.shop
  end
end
