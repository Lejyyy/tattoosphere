class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  layout "admin"

  private

  def require_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Accès refusé."
    end
  end

  def log_action(action, target, note = nil)
    AdminLog.create!(
      admin_user: current_user,
      action:     action,
      target_type: target.class.name,
      target_id:   target.id,
      note:        note
    )
  end
end
