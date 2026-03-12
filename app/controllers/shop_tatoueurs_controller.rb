class ShopTatoueursController < ApplicationController
  before_action :set_shop

  def create
    @shop.tatoueurs << Tatoueur.find(params[:tatoueur_id])
    redirect_to @shop, notice: "Tatoueur ajouté au shop"
  end

  def destroy
    @shop.tatoueurs.delete(Tatoueur.find(params[:tatoueur_id]))
    redirect_to @shop, notice: "Tatoueur retiré du shop"
  end

  private

  def set_shop
    @shop = Shop.find(params[:shop_id])
  end
end
