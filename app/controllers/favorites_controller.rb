# app/controllers/favorites_controller.rb
class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorite_tatoueurs       = current_user.favorite_tatoueurs
    @favorite_shops           = current_user.favorite_shops
    @favorite_portfolios      = current_user.favorite_portfolios
    @favorite_portfolio_items = current_user.favorite_portfolio_items
  end

  def create
    @favoritable = find_favoritable
    @favorite = current_user.favorites.new(favoritable: @favoritable)

    if @favorite.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  end

  def destroy
    @favoritable = find_favoritable
    @favorite = current_user.favorites.find_by!(favoritable: @favoritable)

    @favorite.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def find_favoritable
    if params[:tatoueur_id]
      Tatoueur.find(params[:tatoueur_id])
    elsif params[:shop_id]
      Shop.find(params[:shop_id])
    elsif params[:portfolio_id]
      Portfolio.find(params[:portfolio_id])
    elsif params[:portfolio_item_id]
      PortfolioItem.find(params[:portfolio_item_id])
    end
  end
end
