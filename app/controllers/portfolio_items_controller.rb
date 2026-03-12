class PortfolioItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_tatoueur_and_portfolio
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]

  def index
    @items = @portfolio.portfolio_items
  end

  def show; end

  def new
    @portfolio_item = PortfolioItem.new
  end

  def create
    @portfolio_item = @portfolio.portfolio_items.new(portfolio_item_params)
    if @portfolio_item.save
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Réalisation ajoutée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @portfolio_item.update(portfolio_item_params)
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Réalisation mise à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @portfolio_item.destroy
    redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Réalisation supprimée"
  end

  private

  def set_tatoueur_and_portfolio
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
    @portfolio = @tatoueur.portfolios.find(params[:portfolio_id])
  end

  def set_item
    @portfolio_item = @portfolio.portfolio_items.find(params[:id])
  end

  def portfolio_item_params
  params.require(:portfolio_item).permit(
    :description, :price,
    tattoo_style_ids: [],
    images: []
  )
  end
end
