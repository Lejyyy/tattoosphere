class ShopPanel::PhotosController < ShopPanel::BaseController
  def index; end

  def update
    if params[:shop][:photos].present?
      current_shop.photos.attach(params[:shop][:photos])
    end
    if params[:shop][:cover].present?
      current_shop.cover.attach(params[:shop][:cover])
    end
    if params[:shop][:cover_color].present?
      current_shop.update(cover_color: params[:shop][:cover_color])
    end
    if params[:shop][:remove_cover] == "1"
      current_shop.cover.purge
    end
    redirect_to shop_panel_photos_path, notice: "Photos mises à jour."
  end
end
