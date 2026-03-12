class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

  # Redirige avec un message si accès refusé
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_back(fallback_location: root_path)
  end
end
