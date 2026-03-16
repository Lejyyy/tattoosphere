class TatoueurPanel::AvailabilitiesController < TatoueurPanel::BaseController
  def index
    redirect_to tatoueur_availabilities_path(current_tatoueur)
  end
end
