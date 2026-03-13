class TatoueursController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_tatoueur, only: [ :show, :edit, :update, :destroy ]

  # GET /tatoueurs
  def index
    @tatoueurs = Tatoueur.where(is_active: true)
    @tatoueurs = @tatoueurs.joins(:tattoo_styles)
                           .where(tattoo_styles: { id: params[:style_id] }) if params[:style_id].present?
    @tatoueurs = @tatoueurs.near(params[:location], 50) if params[:location].present?

    @tatoueurs_json = @tatoueurs.where.not(latitude: nil).map do |t|
      {
        id:     t.id,
        name:   t.nickname,
        lat:    t.latitude,
        lng:    t.longitude,
        styles: t.tattoo_styles.map(&:name).join(", "),
        url:    tatoueur_path(t),
        type:   "tatoueur"
      }
    end.to_json
  end

  # GET /tatoueurs/:id
  def show
    authorize @tatoueur
    @portfolios = @tatoueur.portfolios.includes(:portfolio_items)
    @reviews    = @tatoueur.reviews.includes(:user).order(created_at: :desc)
    @events     = @tatoueur.events.order(start_date: :asc)
  end

  # GET /tatoueurs/new
  def new
    # Empêche un user d'avoir deux profils tatoueur
    if current_user.tatoueur.present?
      redirect_to tatoueur_path(current_user.tatoueur), alert: "Vous avez déjà un profil tatoueur."
      return
    end
    @tatoueur = Tatoueur.new
    authorize @tatoueur
  end

  # POST /tatoueurs
  def create
    @tatoueur = Tatoueur.new(tatoueur_params)
    @tatoueur.user = current_user
    authorize @tatoueur
    if @tatoueur.save
      current_user.update!(role: "tatoueur")
      redirect_to @tatoueur, notice: "Profil tatoueur créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tatoueurs/:id/edit
  def edit
    authorize @tatoueur
  end

  # PATCH /tatoueurs/:id
  def update
    authorize @tatoueur
    if @tatoueur.update(tatoueur_params)
      redirect_to @tatoueur, notice: "Profil mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tatoueurs/:id
  def destroy
    authorize @tatoueur
    @tatoueur.update(is_active: false)
    redirect_to tatoueurs_path, notice: "Profil désactivé."
  end

  # GET /tatoueurs/:id/verification
  def verification
    authorize @tatoueur
    redirect_to @tatoueur, notice: "Votre profil est déjà vérifié." if @tatoueur.verified?
  end

  # POST /tatoueurs/:id/submit_verification
  def submit_verification
    authorize @tatoueur

    if @tatoueur.pending_verification?
      redirect_to tatoueur_path(@tatoueur), alert: "Une demande est déjà en cours d'examen." and return
    end

    if @tatoueur.update(verification_params)
      if @tatoueur.submit_for_verification!
        TatoueurMailer.verification_submitted(@tatoueur).deliver_later
        redirect_to tatoueur_path(@tatoueur), notice: "Votre demande de vérification a été envoyée."
      else
        redirect_to verification_tatoueur_path(@tatoueur),
                    alert: "Certains documents sont manquants. Vérifiez votre dossier."
      end
    else
      render :verification, status: :unprocessable_entity
    end
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:id])
  end

  def tatoueur_params
    params.require(:tatoueur).permit(
      :nickname, :first_name, :last_name,
      :email, :phone, :description,
      :address, :deposit_amount,
      :iban, :bic, :bank_name,
      :avatar,
      :identity_document,
      :hygiene_certificate,
      :siren,
      tattoo_style_ids: []
    )
  end

  def verification_params
    params.require(:tatoueur).permit(
      :identity_document,
      :hygiene_certificate,
      :siren,
      :iban, :bic, :bank_name
    )
  end
end
