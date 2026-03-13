class ShopsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_shop, only: [ :show, :edit, :update, :destroy, :add_tatoueur, :remove_tatoueur ]

  def index
  @shops = Shop.where(is_active: true)
  @shops = @shops.near(params[:location], 50) if params[:location].present?

  @shops_json = @shops.where.not(latitude: nil)
                      .map { |s| {
                        id: s.id, name: s.name,
                        lat: s.latitude, lng: s.longitude,
                        address: s.address,
                        url: shop_path(s), type: "shop"
                      }}.to_json
  end

  def show
    authorize @shop
    @tatoueurs = @shop.tatoueurs
    @events = @shop.events
  end

  def new
    @shop = Shop.new
    authorize @shop
  end

  def create
    @shop = Shop.new(shop_params)
    @shop.user = current_user
    authorize @shop
    if @shop.save
      redirect_to @shop, notice: "Shop créé avec succès"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @shop
  end

  def update
    authorize @shop
    if @shop.update(shop_params)
      redirect_to @shop, notice: "Shop mis à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @shop
    @shop.update(is_active: false)
    redirect_to shops_path, notice: "Shop désactivé"
  end

  def add_tatoueur
    authorize @shop
    @shop.tatoueurs << Tatoueur.find(params[:tatoueur_id])
    redirect_to @shop, notice: "Tatoueur ajouté"
  end

  def remove_tatoueur
    authorize @shop
    @shop.tatoueurs.delete(Tatoueur.find(params[:tatoueur_id]))
    redirect_to @shop, notice: "Tatoueur retiré"
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end

  def shop_params
  params.require(:shop).permit(
    :name, :email, :address, :phone,
    :description, :open_hours, :cover,
    photos: []
  )
end
end
