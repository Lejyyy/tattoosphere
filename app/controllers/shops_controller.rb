class ShopsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_shop, only: [ :show, :edit, :update, :destroy, :add_tatoueur, :remove_tatoueur ]

  # GET /shops
  def index
  @shops = Shop.where(is_active: true)
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
  @shop      = Shop.find(params[:id])
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
  @shop = Shop.find(params[:id])
  authorize @shop
end


  # PATCH /shops/:id
  def update
    @shop = Shop.find(params[:id])
    authorize @shop
    if @shop.update(shop_params)
      redirect_to @shop, notice: "Shop mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /shops/:id
  def destroy
    @shop = Shop.find(params[:id])
    authorize @shop
    @shop.update(is_active: false)
    redirect_to shops_path, notice: "Shop désactivé."
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
      :name, :email, :address, :phone,
      :description, :open_hours, :is_active,
      :cover, photos: []
    )
  end
end
