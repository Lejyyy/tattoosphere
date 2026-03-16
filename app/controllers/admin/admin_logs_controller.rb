class Admin::AdminLogsController < Admin::BaseController
  def index
    @logs = AdminLog.recent.includes(:admin_user).page(params[:page]).per(50)
    @logs = @logs.where(action: params[:action_filter]) if params[:action_filter].present?
  end
end
