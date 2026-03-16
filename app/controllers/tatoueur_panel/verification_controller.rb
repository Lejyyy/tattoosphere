class TatoueurPanel::VerificationController < TatoueurPanel::BaseController
  def index
    redirect_to verification_tatoueur_path(current_tatoueur)
  end
end
