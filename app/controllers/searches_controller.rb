class SearchesController < ApplicationController
  skip_before_action :authenticate_user!

  # GET /search
  def index
    @query     = params[:query].presence
    @tatoueurs = search_tatoueurs
    @shops     = search_shops

    # JSON pour la carte
    @results_json = (@tatoueurs.map do |t|
      next unless t.latitude && t.longitude
      {
        id:     t.id,
        name:   t.nickname,
        lat:    t.latitude,
        lng:    t.longitude,
        styles: t.tattoo_styles.map(&:name).join(", "),
        url:    tatoueur_path(t),
        type:   "tatoueur"
      }
    end + @shops.map do |s|
      next unless s.latitude && s.longitude
      {
        id:      s.id,
        name:    s.name,
        lat:     s.latitude,
        lng:     s.longitude,
        address: s.address,
        url:     shop_path(s),
        type:    "shop"
      }
    end).compact.to_json

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def search_tatoueurs
    tatoueurs = Tatoueur.where(is_active: true)
                        .includes(:tattoo_styles, :shops)

    if params[:query].present?
      tatoueurs = tatoueurs.where(
        "nickname ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q",
        q: "%#{params[:query]}%"
      )
    end

    if params[:style_id].present?
      tatoueurs = tatoueurs.joins(:tattoo_styles)
                           .where(tattoo_styles: { id: params[:style_id] })
    end

    if params[:location].present?
      tatoueurs = tatoueurs.near(params[:location], 50)
    end

    if params[:day].present?
      tatoueurs = tatoueurs.joins(:availabilities)
                           .where(availabilities: { day_of_week: params[:day] })
    end

    if params[:price_min].present? || params[:price_max].present?
      tatoueurs = tatoueurs.joins(portfolios: :portfolio_items)
      tatoueurs = tatoueurs.where("portfolio_items.price >= ?", params[:price_min].to_f) if params[:price_min].present?
      tatoueurs = tatoueurs.where("portfolio_items.price <= ?", params[:price_max].to_f) if params[:price_max].present?
    end

    tatoueurs.distinct
  end

  def search_shops
    shops = Shop.where(is_active: true)

    if params[:query].present?
      shops = shops.where("name ILIKE ?", "%#{params[:query]}%")
    end

    if params[:location].present?
      shops = shops.near(params[:location], 50)
    end

    shops.distinct
  end
end
