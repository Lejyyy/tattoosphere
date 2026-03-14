class Admin::TatoueursController < Admin::BaseController
  before_action :set_tatoueur, only: [ :show, :update ]

  def index
    @tatoueurs = Tatoueur.order(created_at: :desc)
    @tatoueurs = @tatoueurs.where(verification_status: params[:status]) if params[:status].present?
  end

  def show
  end

  def update
    case params[:action_type]
    when "approve"
      @tatoueur.approve_verification!
      TatoueurMailer.verification_approved(@tatoueur).deliver_later
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur vérifié ✅"
    when "reject"
      @tatoueur.reject_verification!(params[:reason])
      TatoueurMailer.verification_rejected(@tatoueur).deliver_later
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur refusé."
    when "activate"
      @tatoueur.update(is_active: true)
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur activé."
    when "deactivate"
      @tatoueur.update(is_active: false)
      redirect_to admin_tatoueur_path(@tatoueur), notice: "Tatoueur désactivé."
    end
  end

  private

  def set_tatoueur
    @tatoueur = Tatoueur.find(params[:id])
  end
end
