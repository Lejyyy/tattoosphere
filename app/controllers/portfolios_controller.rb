class PortfoliosController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_tatoueur
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_tatoueur!, except: [ :index, :show ]

  # GET /tatoueurs/:tatoueur_id/portfolios
  def index
    @portfolios = @tatoueur.portfolios.includes(:portfolio_items)
  end

  # GET /tatoueurs/:tatoueur_id/portfolios/:id
  def show
    @items = @portfolio.portfolio_items.includes(:tattoo_styles)
  end

  # GET /tatoueurs/:tatoueur_id/portfolios/new
  def new
    @portfolio = Portfolio.new
  end

  # POST /tatoueurs/:tatoueur_id/portfolios
  def create
    @portfolio = @tatoueur.portfolios.new(portfolio_params)
    if @portfolio.save
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Portfolio créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tatoueurs/:tatoueur_id/portfolios/:id/edit
  def edit; end

  # PATCH /tatoueurs/:tatoueur_id/portfolios/:id
  def update
    if @portfolio.update(portfolio_params)
      redirect_to tatoueur_portfolio_path(@tatoueur, @portfolio), notice: "Portfolio mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tatoueurs/:tatoueur_id/portfolios/:id
  def destroy
    @portfolio.destroy
    redirect_to tatoueur_portfolios_path(@tatoueur), notice: "Portfolio supprimé."
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:tatoueur_id])
  end

  def set_portfolio
    @portfolio = @tatoueur.portfolios.find(params[:id])
  end

  def authorize_tatoueur!
  is_tatoueur_owner = current_user.tatoueur == @tatoueur
  is_shop_owner     = current_user.shop.present? && current_user.shop.tatoueurs.include?(@tatoueur)

  unless is_tatoueur_owner || is_shop_owner || current_user.admin?
    redirect_to tatoueur_portfolios_path(@tatoueur),
                alert: "Vous n'êtes pas autorisé à effectuer cette action."
  end
end

  def portfolio_params
    params.require(:portfolio).permit(:name, :description)
  end
end
