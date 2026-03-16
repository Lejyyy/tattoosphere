class TatoueurPanel::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_tatoueur!
  layout "tatoueur_panel"

  private

  def require_tatoueur!
    unless current_user.tatoueur.present?
      redirect_to root_path, alert: "Accès réservé aux tatoueurs."
    end
  end

  def current_tatoueur
    @current_tatoueur ||= current_user.tatoueur
  end
  helper_method :current_tatoueur
end
