class ShopPortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shop

  def new
    @portfolio = Portfolio.new
    @tatoueurs = @shop.tatoueurs.where(is_active: true)
    authorize @shop, :update?
  end

  def create
    @tatoueur  = @shop.tatoueurs.find(params[:portfolio][:tatoueur_id])
    @portfolio = @tatoueur.portfolios.new(portfolio_params)
    authorize @shop, :update?

    if @portfolio.save
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio),
                  notice: "Portfolio créé."
    else
      @tatoueurs = @shop.tatoueurs.where(is_active: true)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_shop
    @shop = Shop.find(params[:shop_id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:name, :description)
  end
end
