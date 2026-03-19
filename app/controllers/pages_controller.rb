class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  def home
    @tatoueurs = Tatoueur.where(is_active: true)
                         .includes(:tattoo_styles, :reviews, :shops,
                                   avatar_attachment: :blob)
                         .order(created_at: :desc)
                         .limit(4)

    @shops = Shop.where(is_active: true)
                 .includes(:tatoueurs, cover_attachment: :blob)
                 .order(created_at: :desc)
                 .limit(3)

    @events = Event.where(is_public: true)
                   .where("start_date >= ?", Time.current)
                   .includes(:tatoueur, :shop)
                   .order(start_date: :asc)
                   .limit(3)
  end

  def faq
  end

  def cgu
  end

  def mentions_legales
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
