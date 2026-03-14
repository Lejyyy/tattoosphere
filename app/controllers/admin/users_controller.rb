class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.order(created_at: :desc)
    @users = @users.where("nickname ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Utilisateur mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.update(is_active: false)
    redirect_to admin_users_path, notice: "Compte désactivé."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role, :is_active, :first_name, :last_name, :nickname, :email)
  end
end
