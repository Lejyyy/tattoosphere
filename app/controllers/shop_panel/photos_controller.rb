class ShopPanel::PhotosController < ShopPanel::BaseController
  before_action :set_photo, only: [ :update, :destroy ]

  def index
    @photos        = current_shop.gallery_photos.ordered.includes(:tattoo_style, image_attachment: :blob)
    @tattoo_styles = TattooStyle.order(:name)
  end

  def create
    files = params[:photos]
    if files.present?
      Array(files).each_with_index do |file, i|
        photo = current_shop.gallery_photos.build(
          position:        current_shop.gallery_photos.count + i,
          tattoo_style_id: params[:tattoo_style_id].presence,
          title:           params[:title].presence,
          description:     params[:description].presence
        )
        photo.image.attach(file)
        photo.save!
      end
      redirect_to shop_panel_photos_path, notice: "#{Array(files).count} photo(s) ajoutée(s)."
    else
      redirect_to shop_panel_photos_path, alert: "Aucune photo sélectionnée."
    end
  end

  def update
    if params[:position].present?
      @photo.update(position: params[:position])
      render json: { status: "ok" } and return
    end
    if @photo.update(photo_params)
      redirect_to shop_panel_photos_path, notice: "Photo mise à jour."
    else
      redirect_to shop_panel_photos_path, alert: "Erreur lors de la mise à jour."
    end
  end

  def destroy
    @photo.image.purge
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to shop_panel_photos_path, notice: "Photo supprimée." }
      format.json { render json: { status: "ok" } }
    end
  end

  def reorder
    params[:order].each_with_index do |id, i|
      current_shop.gallery_photos.where(id: id).update_all(position: i)
    end
    render json: { status: "ok" }
  end

  def update_cover
    if params[:shop][:cover].present?
      current_shop.cover.attach(params[:shop][:cover])
    end
    if params[:shop][:cover_color].present?
      current_shop.update(cover_color: params[:shop][:cover_color])
    end
    if params[:shop][:remove_cover] == "1"
      current_shop.cover.purge
    end
    redirect_to shop_panel_photos_path, notice: "Couverture mise à jour."
  end

  private

  def set_photo
    @photo = current_shop.gallery_photos.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:title, :description, :tattoo_style_id)
  end
end
