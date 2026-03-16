class ExploreController < ApplicationController
  def index
    tatoueurs = Tatoueur.where(is_active: true)
                        .includes(:tattoo_styles, avatar_attachment: :blob)

    # ── Filtre par style ──────────────────────────────────────
    if params[:style_id].present?
      tatoueurs = tatoueurs.joins(:tattoo_styles)
                           .where(tattoo_styles: { id: params[:style_id] })
    end

    # ── Filtre géographique ───────────────────────────────────
    if params[:near].present?
      tatoueurs = tatoueurs.near(params[:near], params[:distance] || 5)
    end

    # ── Filtre par ville ──────────────────────────────────────
    if params[:city].present?
      tatoueurs = tatoueurs.near(params[:city], 20)
    end

    # ── Filtre par portfolio ──────────────────────────────────
    if params[:portfolio_id].present?
      portfolio = Portfolio.find_by(id: params[:portfolio_id])
      items = portfolio ? portfolio.portfolio_items
                                   .includes(images_attachments: :blob)
                                   .where.not(images_attachments: { id: nil }) : PortfolioItem.none
      @realisations = build_from_items(items, {})
      @tattoo_styles = TattooStyle.order(:name)
      @portfolios    = Portfolio.joins(:portfolio_items).distinct.order(:name)
      return
    end

    # ── Construction du feed unifié ───────────────────────────
    tatoueur_ids = tatoueurs.pluck(:id)

    # PortfolioItems avec images
    portfolio_items = PortfolioItem
      .joins(:portfolio)
      .where(portfolios: { tatoueur_id: tatoueur_ids })
      .includes(:tattoo_styles, :portfolio, images_attachments: :blob,
                portfolio: { tatoueur: [ avatar_attachment: :blob ] })
      .where.not(images_attachments: { id: nil })

    if params[:style_id].present?
      portfolio_items = portfolio_items
        .joins(:tattoo_styles)
        .where(tattoo_styles: { id: params[:style_id] })
    end

    # Photos libres des tatoueurs
    tatoueurs_with_photos = Tatoueur
      .where(id: tatoueur_ids, is_active: true)
      .includes(:tattoo_styles, avatar_attachment: :blob,
                photos_attachments: :blob)
      .select { |t| t.photos.attached? }

    # ── Normalisation en objets uniformes ─────────────────────
    feed = []

    portfolio_items.each do |item|
      item.images.each do |img|
        feed << {
          type:       :portfolio_item,
          image:      img,
          created_at: item.created_at,
          tatoueur:   item.portfolio.tatoueur,
          styles:     item.tattoo_styles,
          price:      item.price,
          description: item.description,
          source_path: tatoueur_path(item.portfolio.tatoueur)
        }
      end
    end

    tatoueurs_with_photos.each do |tatoueur|
      tatoueur.photos.each do |photo|
        blob = photo.blob
        feed << {
          type:        :free_photo,
          image:       photo,
          created_at:  blob.created_at,
          tatoueur:    tatoueur,
          styles:      tatoueur.tattoo_styles,
          price:       nil,
          description: nil,
          source_path: tatoueur_path(tatoueur)
        }
      end
    end

    # ── Tri par date décroissante ─────────────────────────────
    feed.sort_by! { |r| r[:created_at] }.reverse!

    @realisations  = feed
    @tattoo_styles = TattooStyle.order(:name)
    @portfolios    = Portfolio.joins(:portfolio_items).distinct.order(:name)
  end

  private

  def build_from_items(items, _opts)
    items.flat_map do |item|
      item.images.map do |img|
        {
          type:        :portfolio_item,
          image:       img,
          created_at:  item.created_at,
          tatoueur:    item.portfolio.tatoueur,
          styles:      item.tattoo_styles,
          price:       item.price,
          description: item.description,
          source_path: tatoueur_path(item.portfolio.tatoueur)
        }
      end
    end
  end
end
