class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  # GET /
  def home
    @shops     = Shop.where(is_active: true).limit(3)
    @tatoueurs = Tatoueur.where(is_active: true).includes(:tattoo_styles).limit(4)
    @events    = Event.where(is_public: true).where("start_date >= ?", Date.today).order(:start_date).limit(3)
  end

  # GET /map
  def map
    @tatoueurs = Tatoueur.where(is_active: true)
                         .where.not(latitude: nil, longitude: nil)
                         .includes(:tattoo_styles)

    @shops     = Shop.where(is_active: true)
                     .where.not(latitude: nil, longitude: nil)

    @tatoueurs_json = @tatoueurs.map do |t|
      {
        id:     t.id,
        name:   t.nickname,
        lat:    t.latitude,
        lng:    t.longitude,
        styles: t.tattoo_styles.map(&:name).join(", "),
        url:    tatoueur_path(t),
        type:   "tatoueur",
        avatar: t.avatar.attached? ? url_for(t.avatar) : nil
      }
    end.to_json

    @shops_json = @shops.map do |s|
      {
        id:      s.id,
        name:    s.name,
        lat:     s.latitude,
        lng:     s.longitude,
        address: s.address,
        url:     shop_path(s),
        type:    "shop"
      }
    end.to_json
  end
end
