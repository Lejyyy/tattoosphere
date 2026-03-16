class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @users_count       = User.count
    @tatoueurs_count   = Tatoueur.count
    @shops_count       = Shop.count
    @events_count      = Event.count
    @pending_verifs    = Tatoueur.where(verification_status: "pending")
    @pending_reports   = Report.pending.count
    @recent_users      = User.order(created_at: :desc).limit(5)
    @recent_logs       = AdminLog.recent.limit(10).includes(:admin_user)

    # Stats 30 derniers jours
    @new_users_30d     = User.where("created_at >= ?", 30.days.ago).count
    @new_bookings_30d  = Booking.where("created_at >= ?", 30.days.ago).count
    @new_tatoueurs_30d = Tatoueur.where("created_at >= ?", 30.days.ago).count
  end

  def stats
    @users_by_week = User.group_by_week(:created_at, last: 12).count
    @bookings_by_week = Booking.group_by_week(:created_at, last: 12).count
    @top_tatoueurs = Tatoueur.joins(:bookings)
                             .group("tatoueurs.id", "tatoueurs.nickname")
                             .order("count_all desc").limit(10)
                             .count
    @top_cities = Tatoueur.where.not(address: nil)
                          .group(:address).order("count_all desc").limit(10).count
  end

  def show
  @bookings = current_user.bookings.includes(:tatoueur, :shop).order(date: :desc)
  @conversations = current_user.conversations
                               .includes(:messages, :conversation_participants)
                               .order("messages.created_at DESC")
                               .limit(5)
  @unread_count = @conversations.sum { |c| c.unread_count_for(current_user) }
  @tatoueur = current_user.tatoueur
  @shop     = current_user.shop
end
end
