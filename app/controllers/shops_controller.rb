class ShopsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_shop, only: [
    :show, :edit, :update, :destroy,
    :add_tatoueur, :remove_tatoueur,
    :update_profile_photo
  ]

  # GET /shops
  def index
    @shops = Shop.where(is_active: true, banned: false)
             .order(featured: :desc, created_at: :desc)
             .includes(:tatoueurs,
                       cover_attachment: :blob,
                       photos_attachments: :blob)

    @shops = @shops.near(params[:location], 50) if params[:location].present?

    @shops_json = @shops.where.not(latitude: nil).map do |s|
      {
        id:   s.id,
        name: s.name,
        lat:  s.latitude,
        lng:  s.longitude,
        url:  shop_path(s),
        type: "shop"
      }
    end.to_json
  end

  # GET /shops/:id
  def show
    authorize @shop
    @tatoueurs = @shop.tatoueurs.includes(:tattoo_styles).where(is_active: true)
    @events    = @shop.events.where("start_date >= ?", Time.current).order(start_date: :asc)
  end

  # GET /shops/new
  def new
    if current_user.shop.present?
      redirect_to shop_path(current_user.shop), alert: "Vous avez déjà un shop."
      return
    end
    @shop = Shop.new
    authorize @shop
  end

  # POST /shops
  def create
    @shop = Shop.new(shop_params)
    @shop.user = current_user
    authorize @shop
    if @shop.save
      redirect_to @shop, notice: "Shop créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /shops/:id/edit
  def edit
    authorize @shop
  end

  # PATCH /shops/:id
  def update
    authorize @shop

    # Gestion de la cover
    if params[:shop]&.[](:remove_cover) == "1" || params[:preset_cover_url].present?
      @shop.cover.purge if @shop.cover.attached?
    end

    if params[:preset_cover_url].present?
      filename  = File.basename(params[:preset_cover_url])
      file_path = Rails.root.join("public/covers", filename)
      if File.exist?(file_path)
        @shop.cover.attach(
          io: File.open(file_path),
          filename: filename,
          content_type: Marcel::MimeType.for(Pathname.new(file_path))
        )
      end
    end

    if params[:shop][:photos].present?
      @shop.photos.attach(params[:shop][:photos])
    end

    if @shop.update(shop_params)
      redirect_to @shop, notice: "Shop mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  # DELETE /shops/:id
  def destroy
    authorize @shop
    @shop.update(is_active: false)
    redirect_to shops_path, notice: "Shop désactivé."
  end

  # PATCH /shops/:id/update_profile_photo
  def update_profile_photo
    authorize @shop
    if params[:remove_profile_photo] == "1" && @shop.photos.first
      @shop.photos.first.purge
    end
    redirect_to edit_shop_path(@shop), notice: "Photo de profil supprimée."
  end

  # POST /shops/:id/add_tatoueur
  def add_tatoueur
    authorize @shop
    tatoueur = Tatoueur.find(params[:tatoueur_id])
    if @shop.tatoueurs.include?(tatoueur)
      redirect_to @shop, alert: "Ce tatoueur est déjà associé à ce shop."
    else
      ShopTatoueur.create!(shop: @shop, tatoueur: tatoueur, start_date: Date.today)
      redirect_to @shop, notice: "#{tatoueur.nickname} ajouté au shop."
    end
  end

  # DELETE /shops/:id/remove_tatoueur
  def remove_tatoueur
    authorize @shop
    tatoueur    = Tatoueur.find(params[:tatoueur_id])
    association = ShopTatoueur.find_by(shop: @shop, tatoueur: tatoueur)
    if association
      association.update!(end_date: Date.today + 1.day)
      respond_to do |format|
        format.html { redirect_to @shop, notice: "#{tatoueur.nickname} retiré du shop." }
        format.json { head :ok }
        format.any  { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to @shop, alert: "Ce tatoueur n'est pas associé à ce shop." }
        format.json { head :unprocessable_entity }
        format.any  { head :unprocessable_entity }
      end
    end
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end

  def shop_params
    params.require(:shop).permit(
      :name, :address, :description,
      :email, :phone, :open_hours,
      :cover, :cover_color
    )
  end
end
