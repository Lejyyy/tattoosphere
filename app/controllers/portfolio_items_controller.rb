class PortfolioItemsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_tatoueur_and_portfolio
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_tatoueur!, except: [ :index, :show ]

  # GET /tatoueurs/:tatoueur_id/portfolios/:portfolio_id/portfolio_items
  def index
    @items = @portfolio.portfolio_items.includes(:tattoo_styles)
  end

  # GET /tatoueurs/:tatoueur_id/portfolios/:portfolio_id/portfolio_items/:id
  def show; end

  # GET /tatoueurs/:tatoueur_id/portfolios/:portfolio_id/portfolio_items/new
  def new
    @portfolio_item = PortfolioItem.new
  end

  # POST /tatoueurs/:tatoueur_id/portfolios/:portfolio_id/portfolio_items
  def create
    @portfolio_item = @portfolio.portfolio_items.new(portfolio_item_params)
    if @portfolio_item.save
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Réalisation ajoutée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tatoueurs/:tatoueur_id/portfolios/:portfolio_id/portfolio_items/:id/edit
  def edit; end

  # PATCH /tatoueurs/:tatoueur_id/portfolios/:portfolio_id/portfolio_items/:id
  def update
    if @portfolio_item.update(portfolio_item_params)
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Réalisation mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tatoueurs/:tatoueur_id/portfolios/:portfolio_id/portfolio_items/:id
  def destroy
    @portfolio_item.destroy
    redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Réalisation supprimée."
  end

  private

  def set_tatoueur_and_portfolio
    @tatoueur  = Tatoueur.find(params[:tatoueur_id])
    @portfolio = @tatoueur.portfolios.find(params[:portfolio_id])
  end

  def set_item
    @portfolio_item = @portfolio.portfolio_items.find(params[:id])
  end

  def authorize_tatoueur!
    unless current_user.tatoueur == @tatoueur
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), alert: "Vous n'êtes pas autorisé à effectuer cette action."
    end
  end

  def portfolio_item_params
    params.require(:portfolio_item).permit(
      :description, :price,
      tattoo_style_ids: [],
      images: []
    )
  end
end
