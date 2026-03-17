class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.limit(50)
    @unread_count  = current_user.notifications.unread.count
  end

  def mark_as_read
    notif = current_user.notifications.find(params[:id])
    notif.mark_as_read!
    redirect_to notif.url || notifications_path
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)
    redirect_to notifications_path
  end

  def destroy
    current_user.notifications.find(params[:id]).destroy
    redirect_to notifications_path, status: :see_other
  end
end
