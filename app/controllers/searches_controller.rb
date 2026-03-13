class SearchesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @tatoueurs = search_tatoueurs
    @shops     = search_shops

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def search_tatoueurs
    tatoueurs = Tatoueur.where(is_active: true)
                        .includes(:tattoo_styles, :shops)

    # Filtre par nom
    if params[:query].present?
      tatoueurs = tatoueurs.where(
        "nickname ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q",
        q: "%#{params[:query]}%"
      )
    end

    # Filtre par style
    if params[:style_id].present?
      tatoueurs = tatoueurs.joins(:tattoo_styles)
                           .where(tattoo_styles: { id: params[:style_id] })
    end

    # Filtre par localisation (rayon 50km)
    if params[:location].present?
      tatoueurs = tatoueurs.near(params[:location], 50)
    end

    # Filtre par disponibilité (jour de la semaine)
    if params[:day].present?
      tatoueurs = tatoueurs.joins(:availabilities)
                           .where(availabilities: { day_of_week: params[:day] })
    end

    # Filtre par prix min/max via portfolio_items
    if params[:price_min].present? || params[:price_max].present?
      tatoueurs = tatoueurs.joins(portfolios: :portfolio_items)
      tatoueurs = tatoueurs.where("portfolio_items.price >= ?", params[:price_min]) if params[:price_min].present?
      tatoueurs = tatoueurs.where("portfolio_items.price <= ?", params[:price_max]) if params[:price_max].present?
    end

    tatoueurs.distinct
  end

  def search_shops
    shops = Shop.where(is_active: true)

    # Filtre par nom
    if params[:shop_name].present?
      shops = shops.where("name ILIKE ?", "%#{params[:shop_name]}%")
    end

    # Filtre par localisation
    if params[:location].present?
      shops = shops.near(params[:location], 50)
    end

    shops.distinct
  end
end
