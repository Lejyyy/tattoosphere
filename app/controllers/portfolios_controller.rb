class PortfoliosController < ApplicationController
 skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_tatoueur
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy ]

  def index
    @portfolios = @tatoueur.portfolios
  end

  def show
    @items = @portfolio.portfolio_items
  end

  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = @tatoueur.portfolios.new(portfolio_params)
    if @portfolio.save
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Portfolio créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @portfolio.update(portfolio_params)
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Portfolio mis à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @portfolio.destroy
    redirect_to tatoueur_portfolios_path(@tatoueur), notice: "Portfolio supprimé"
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
  end

  def set_portfolio
    @portfolio = @tatoueur.portfolios.find(params[:id])
  end

  def portfolio_item_params
  params.require(:portfolio_item).permit(
    :description, :price,
    tattoo_style_ids: [],
    images: []
  )
end
end
