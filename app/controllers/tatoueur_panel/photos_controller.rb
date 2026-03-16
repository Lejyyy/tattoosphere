class TatoueurPanel::PhotosController < TatoueurPanel::BaseController
  def index; end

  def update
    if params[:tatoueur][:photos].present?
      current_tatoueur.photos.attach(params[:tatoueur][:photos])
    end
    if params[:tatoueur][:cover].present?
      current_tatoueur.cover.attach(params[:tatoueur][:cover])
    end
    if params[:tatoueur][:cover_color].present?
      current_tatoueur.update(cover_color: params[:tatoueur][:cover_color])
    end
    if params[:tatoueur][:remove_cover] == "1"
      current_tatoueur.cover.purge
    end
    redirect_to tatoueur_panel_photos_path, notice: "Photos mises à jour."
  end
end
