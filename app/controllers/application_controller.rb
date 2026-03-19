class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

def authenticate_user_or_json!
  unless user_signed_in?
    respond_to do |format|
      format.json { render json: { error: "non_authentifié", redirect: new_user_session_path }, status: :unauthorized }
      format.html { redirect_to new_user_session_path }
    end
  end
end

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
