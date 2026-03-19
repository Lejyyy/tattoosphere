class TatoueurPanel::PhotosController < TatoueurPanel::BaseController
  before_action :set_photo, only: [ :update, :destroy ]

  def index
    @photos       = current_tatoueur.gallery_photos.ordered.includes(:tattoo_style, image_attachment: :blob)
    @tattoo_styles = TattooStyle.order(:name)
  end

  # POST /tatoueur_panel/photos
  def create
    files = params[:photos]
    if files.present?
      Array(files).each_with_index do |file, i|
        photo = current_tatoueur.gallery_photos.build(
          position:        current_tatoueur.gallery_photos.count + i,
          tattoo_style_id: params[:tattoo_style_id].presence,
          title:           params[:title].presence,
          description:     params[:description].presence
        )
        photo.image.attach(file)
        photo.save!
      end
      respond_to do |format|
        format.html { redirect_to tatoueur_panel_photos_path, notice: "#{Array(files).count} photo(s) ajoutée(s)." }
        format.json { render json: { status: "ok" } }
      end
    else
      redirect_to tatoueur_panel_photos_path, alert: "Aucune photo sélectionnée."
    end
  end

  # PATCH /tatoueur_panel/photos/:id
  def update
    # Réorganisation drag & drop
    if params[:position].present?
      @photo.update(position: params[:position])
      render json: { status: "ok" } and return
    end

    # Mise à jour métadonnées
    if @photo.update(photo_params)
      redirect_to tatoueur_panel_photos_path, notice: "Photo mise à jour."
    else
      redirect_to tatoueur_panel_photos_path, alert: "Erreur lors de la mise à jour."
    end
  end

  # DELETE /tatoueur_panel/photos/:id
  def destroy
    @photo.image.purge
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to tatoueur_panel_photos_path, notice: "Photo supprimée." }
      format.json { render json: { status: "ok" } }
    end
  end

  # PATCH /tatoueur_panel/photos/reorder
  def reorder
    params[:order].each_with_index do |id, i|
      current_tatoueur.gallery_photos.where(id: id).update_all(position: i)
    end
    render json: { status: "ok" }
  end

  # Cover + avatar (ancien controller)
  def update_cover
    if params[:tatoueur][:cover].present?
      current_tatoueur.cover.attach(params[:tatoueur][:cover])
    end
    if params[:tatoueur][:cover_color].present?
      current_tatoueur.update(cover_color: params[:tatoueur][:cover_color])
    end
    if params[:tatoueur][:remove_cover] == "1"
      current_tatoueur.cover.purge
    end
    redirect_to tatoueur_panel_photos_path, notice: "Couverture mise à jour."
  end

  private

  def set_photo
    @photo = current_tatoueur.gallery_photos.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:title, :description, :tattoo_style_id)
  end
end
