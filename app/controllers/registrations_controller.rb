class RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [ :update ]
  before_action :configure_sign_up_params, only: [ :create ]

  protected

  def update_resource(resource, params)
    params.delete(:current_password)
    resource.update_without_password(params)
  end

   def configure_sign_up_params
  devise_parameter_sanitizer.permit(:sign_up, keys: [
    :first_name, :last_name, :nickname, :phone, :birth_date, :avatar, :role,
    preferred_style_ids: []
  ])
end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :nickname, :phone, :birth_date, :avatar ])
  end

  def after_sign_up_path_for(resource)
    dashboard_path
  end

  def after_update_path_for(resource)
    dashboard_path
  end

  def build_resource(hash = {})
    hash[:role] ||= "user"
  super
end

  private

  def sign_up_params
    params.require(:user).permit(
      :first_name, :last_name, :nickname,
      :email, :password, :password_confirmation,
      :avatar
    )
  end

  def account_update_params
    params.require(:user).permit(
      :first_name, :last_name, :nickname,
      :email, :password, :password_confirmation,
      :current_password, :avatar
    )
  end
end
