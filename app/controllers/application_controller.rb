class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError,      with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound,    with: :record_not_found

  private

  def pundit_user
    current_user
  end

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_back(fallback_location: root_path)
  end

  def record_not_found
    flash[:alert] = "La ressource demandée est introuvable."
    redirect_back(fallback_location: root_path)
  end
end
