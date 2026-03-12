class TatoueursController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_tatoueur, only: [ :show, :edit, :update, :destroy ]

  def index
    @tatoueurs = policy_scope(Tatoueur)
    @tatoueurs = @tatoueurs.joins(:tattoo_styles).where(tattoo_styles: { id: params[:style_id] }) if params[:style_id].present?
  end

  def show
    authorize @tatoueur
    @portfolios = @tatoueur.portfolios
    @reviews = @tatoueur.reviews
    @events = @tatoueur.events
  end

  def new
    @tatoueur = Tatoueur.new
    authorize @tatoueur
  end

  def create
    @tatoueur = Tatoueur.new(tatoueur_params)
    @tatoueur.user = current_user
    authorize @tatoueur
    if @tatoueur.save
      redirect_to @tatoueur, notice: "Profil tatoueur créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @tatoueur
  end

  def update
    authorize @tatoueur
    if @tatoueur.update(tatoueur_params)
      redirect_to @tatoueur, notice: "Profil mis à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tatoueur
    @tatoueur.update(is_active: false)
    redirect_to tatoueurs_path, notice: "Tatoueur désactivé"
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:id])
  end

  def tatoueur_params
  params.require(:tatoueur).permit(
    :nickname, :first_name, :last_name,
    :email, :description, :avatar,
    tattoo_style_ids: []
  )
end
end
