class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    @shops     = Shop.where(is_active: true).limit(3)
    @tatoueurs = Tatoueur.where(is_active: true).limit(4)
    @events    = Event.where(is_public: true).order(:start_date).limit(3)
  end

  def map
    @tatoueurs = Tatoueur.where(is_active: true)
                         .where.not(latitude: nil, longitude: nil)
    @shops     = Shop.where(is_active: true)
                     .where.not(latitude: nil, longitude: nil)

    # Données JSON pour Leaflet
    @tatoueurs_json = @tatoueurs.map do |t|
      {
        id:       t.id,
        name:     t.nickname,
        lat:      t.latitude,
        lng:      t.longitude,
        styles:   t.tattoo_styles.map(&:name).join(", "),
        url:      Rails.application.routes.url_helpers.tatoueur_path(t),
        type:     "tatoueur",
        avatar:   t.avatar.attached? ? Rails.application.routes.url_helpers.url_for(t.avatar) : nil
      }
    end.to_json

    @shops_json = @shops.map do |s|
      {
        id:      s.id,
        name:    s.name,
        lat:     s.latitude,
        lng:     s.longitude,
        address: s.address,
        url:     Rails.application.routes.url_helpers.shop_path(s),
        type:    "shop"
      }
    end.to_json
  end
end
