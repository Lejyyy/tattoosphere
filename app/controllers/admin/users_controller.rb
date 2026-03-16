class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :update, :destroy, :ban, :unban ]

  def index
    @users = User.order(created_at: :desc)
    @users = @users.where("email ILIKE ? OR nickname ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    @users = @users.where(role: params[:role]) if params[:role].present?
    @users = @users.where(banned: true)  if params[:filter] == "banned"
    @users = @users.where(banned: false) if params[:filter] == "active"
    @users = @users.page(params[:page]).per(30)
  end

  def show
    @reports = Report.where(reportable: @user)
    @logs    = AdminLog.where(target_type: "User", target_id: @user.id).recent
  end

  def update
    @user.update(user_params)
    log_action("update_user", @user)
    redirect_to admin_user_path(@user), notice: "Utilisateur mis à jour."
  end

  def destroy
    @user.update(banned: true, banned_at: Time.current)
    log_action("delete_user", @user)
    redirect_to admin_users_path, notice: "Utilisateur supprimé."
  end

  def ban
    @user.update(banned: true, banned_at: Time.current)
    log_action("ban_user", @user, params[:note])
    redirect_to admin_user_path(@user), notice: "Utilisateur banni."
  end

  def unban
    @user.update(banned: false, banned_at: nil)
    log_action("unban_user", @user)
    redirect_to admin_user_path(@user), notice: "Bannissement levé."
  end

  private
  def set_user = @user = User.find(params[:id])
  def user_params = params.require(:user).permit(:role, :email, :nickname)
end
